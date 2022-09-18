// Copyright (c) 2021 Open Community Project Association https://ocpa.ch
// This software is published under the AGPLv3 license.

//! # Qaul Messaging Service
//!
//! The messaging service is used for sending, receiving and
//! relay chat messages.

use libp2p::PeerId;
use prost::Message;
use serde::{Deserialize, Serialize};
use sled_extensions::{bincode::Tree, DbExt};
use state::Storage;
use std::collections::VecDeque;
use std::sync::RwLock;

#[cfg(emulate)]
mod network_emul;

pub mod process;
pub mod retransmit;

use super::chat::{ChatFile, ChatStorage};
use super::crypto::Crypto;
use crate::connections::ConnectionModule;
use crate::node::user_accounts::{UserAccount, UserAccounts};
use crate::router::table::RoutingTable;
use crate::storage::database::DataBase;
use crate::utilities::timestamp::Timestamp;
use process::MessagingProcess;
use qaul_messaging::QaulMessagingReceived;

/// Import protobuf message definition generated by
/// the rust module prost-build.
pub mod proto {
    include!("qaul.net.messaging.rs");
}

/// mutable state of messages, scheduled for sending
pub static MESSAGING: Storage<RwLock<Messaging>> = Storage::new();

/// Messaging Scheduling Structure
pub struct ScheduledMessage {
    receiver: PeerId,
    container: proto::Container,
    is_common: bool,
    is_forward: bool,
    scheduled_dtn: bool,
    is_dtn: bool,
}

/// mutable state of messages, scheduled for sending
pub static UNCONFIRMED: Storage<RwLock<UnConfirmedMessages>> = Storage::new();

// TODO: check if it wouldn't be easier to store
// the message
/// unconfirmed message
#[derive(Serialize, Deserialize, Clone)]
pub struct UnConfirmedMessage {
    // receiver id
    pub receiver_id: Vec<u8>,
    // message type
    pub message_type: MessagingServiceType,
    // message id
    pub message_id: Vec<u8>,
    // encoded container
    pub container: Vec<u8>,
    // last sent time
    pub last_sent: u64,
    // retry time
    pub retry: u32,
    // flag that transferred on the network
    pub scheduled: bool,
    // flag that transferred as DTN service
    pub scheduled_dtn: bool,
    // flag that indicate DTN message
    pub is_dtn: bool,
}

/// Unconfirmed Message Type
#[derive(Serialize, Deserialize, Clone)]
pub enum MessagingServiceType {
    /// Unconfirmed Message
    /// (this message does expect a confirmation)
    Unconfirmed,
    /// DTN message, originated from this host
    DtnOrigin,
    /// DTN message, stored on this host
    DtnStored,
    /// Crypto Handshake Message
    Crypto,
    /// Group Management Message
    Group,
    /// Chat Text Message
    Chat,
    /// Chat File Message
    ChatFile,
    /// RTC Message
    Rtc,
}

/// Unconfirmed Messages Structure
pub struct UnConfirmedMessages {
    /// signature => UnConfirmedMessage
    pub unconfirmed: Tree<UnConfirmedMessage>,
}

/// Qaul Messaging Structure
pub struct Messaging {
    /// ring buffer of messages scheduled for sending
    pub to_send: VecDeque<ScheduledMessage>,
}

/// Qaul Failed Message Structure
#[derive(Serialize, Deserialize, Clone)]
pub struct FailedMessage {
    pub user_id: Vec<u8>,
    pub group_id: Vec<u8>,
    pub created_at: u64,
    pub last_try: u64,
    pub try_count: u32,
    pub message: String,
}

impl Messaging {
    /// Initialize messaging and create the ring buffer.
    pub fn init() {
        #[cfg(emulate)]
        /// init emulator
        network_emul::NetworkEmulator::init();

        let messaging = Messaging {
            to_send: VecDeque::new(),
        };
        MESSAGING.set(RwLock::new(messaging));

        let db = DataBase::get_node_db();

        // open trees
        let unconfirmed: Tree<UnConfirmedMessage> = db.open_bincode_tree("unconfirmed").unwrap();
        let unconfirmed_messages = UnConfirmedMessages { unconfirmed };
        UNCONFIRMED.set(RwLock::new(unconfirmed_messages));
    }

    /// Save a message to the data base to wait for confirmation
    pub fn save_unconfirmed_message(
        message_type: MessagingServiceType,
        message_id: &Vec<u8>,
        receiver: &PeerId,
        container: &proto::Container,
        is_dtn: bool,
    ) {
        let new_entry = UnConfirmedMessage {
            receiver_id: receiver.to_bytes(),
            container: container.encode_to_vec(),
            last_sent: Timestamp::get_timestamp(),
            message_type,
            message_id: message_id.to_owned(),
            retry: 1,
            scheduled: false,
            scheduled_dtn: false,
            is_dtn,
        };
        let unconfirmed = UNCONFIRMED.get().write().unwrap();

        // insert message to data base
        if let Err(e) = unconfirmed
            .unconfirmed
            .insert(container.signature.clone(), new_entry)
        {
            log::error!("{}", e);
        }
        // flush
        if let Err(e) = unconfirmed.unconfirmed.flush() {
            log::error!("Error unconfirmed table flush: {}", e);
        }
    }

    /// process confirmation message and return (sender_id, message_id)
    pub fn on_confirmed_message(
        signature: &Vec<u8>,
        sender_id: PeerId,
        user_account: UserAccount,
        confirmation: proto::Confirmation,
    ) {
        log::trace!("messgae confirmed");

        let unconfirmed = UNCONFIRMED.get().write().unwrap();

        // check and remove unconfirmed from DB
        match unconfirmed.unconfirmed.remove(signature) {
            Ok(v) => {
                if let Err(e) = unconfirmed.unconfirmed.flush() {
                    log::error!("Error unconfirmed table flush: {}", e);
                }

                match v {
                    Some(unconfirmed) => {
                        // check message and decide what to do
                        match unconfirmed.message_type {
                            MessagingServiceType::Unconfirmed => {
                                log::debug!("Confirmation: Unconfirmed");
                            }
                            MessagingServiceType::DtnOrigin => {
                                log::debug!("Confirmation: DtnOrigin");
                                // what kind of message do we have here?
                                // TODO: check chat storage as sent ...
                            }
                            MessagingServiceType::DtnStored => {
                                log::debug!("Confirmation: DtnStored");
                            }
                            MessagingServiceType::Crypto => {
                                log::debug!("Confirmation: Crypto");
                            }
                            MessagingServiceType::Group => {
                                log::debug!("Confirmation: Group");
                                // don't do anything for group messages
                            }
                            MessagingServiceType::Chat => {
                                log::debug!("Confirmation: Chat");
                                // set received info in chat data base
                                ChatStorage::update_confirmation(
                                    user_account.id,
                                    sender_id,
                                    &unconfirmed.message_id,
                                    confirmation.received_at,
                                );
                            }
                            MessagingServiceType::ChatFile => {
                                log::trace!("Confirmation: ChatFile");
                                match unconfirmed.message_id.try_into() {
                                    Ok(arr) => {
                                        let file_id = u64::from_be_bytes(arr);

                                        // confirm message reception in data base
                                        ChatFile::update_confirmation(
                                            user_account.id,
                                            sender_id,
                                            file_id,
                                            confirmation.received_at,
                                        );
                                    }
                                    Err(e) => {
                                        log::error!("couldn't convert file_id to u64: {:?}", e);
                                    }
                                }
                            }
                            MessagingServiceType::Rtc => {
                                log::debug!("Confirmation: Rtc");
                                // TODO CONFIRM RTC MESSAGE
                            }
                        }
                    }
                    _ => {}
                }
            }
            Err(e) => {
                log::error!("{}", e);
            }
        }
    }

    fn on_scheduled_message(signature: &Vec<u8>) {
        let unconfirmed = UNCONFIRMED.get().write().unwrap();
        if !unconfirmed.unconfirmed.contains_key(signature).unwrap() {
            return;
        }

        let mut unconfirmed_message = unconfirmed.unconfirmed.get(signature).unwrap().unwrap();
        if unconfirmed_message.scheduled {
            return;
        }

        unconfirmed_message.scheduled = true;
        if let Err(_e) = unconfirmed
            .unconfirmed
            .insert(signature.clone(), unconfirmed_message)
        {
            log::error!("error updating unconfirmed table");
        } else {
            if let Err(_e) = unconfirmed.unconfirmed.flush() {
                log::error!("error updating unconfirmed table");
            }
        }
    }

    fn on_scheduled_as_dtn_message(signature: &Vec<u8>) {
        let unconfirmed = UNCONFIRMED.get().write().unwrap();
        if !unconfirmed.unconfirmed.contains_key(signature).unwrap() {
            return;
        }

        let mut unconfirmed_message = unconfirmed.unconfirmed.get(signature).unwrap().unwrap();
        if unconfirmed_message.scheduled {
            return;
        }

        unconfirmed_message.scheduled_dtn = true;
        if let Err(_e) = unconfirmed
            .unconfirmed
            .insert(signature.clone(), unconfirmed_message)
        {
            log::error!("error updating unconfirmed table");
        } else {
            if let Err(_e) = unconfirmed.unconfirmed.flush() {
                log::error!("error updating unconfirmed table");
            }
        }
    }

    /// pack, sign and schedule a message for sending
    pub fn pack_and_send_message(
        user_account: &UserAccount,
        receiver: &PeerId,
        data: Vec<u8>,
        _message_type: MessagingServiceType,
        message_id: &Vec<u8>,
        is_common_message: bool,
    ) -> Result<Vec<u8>, String> {
        log::debug!("pack_and_send_message to {}", receiver.to_base58());

        // encrypt data
        let encrypted_message: proto::Encrypted;
        let encryption_result = Crypto::encrypt(data, user_account.to_owned(), receiver.clone());

        match encryption_result {
            Some(encrypted) => {
                encrypted_message = encrypted;
            }
            None => return Err("Encryption error occurred".to_string()),
        }

        log::trace!(
            "sender_id: {}, receiver_id: {}",
            user_account.id.to_base58(),
            receiver.to_base58()
        );

        let envelop_payload = proto::EnvelopPayload {
            payload: Some(proto::envelop_payload::Payload::Encrypted(
                encrypted_message,
            )),
        };

        // create envelope
        let envelope = proto::Envelope {
            sender_id: user_account.id.to_bytes(),
            receiver_id: receiver.to_bytes(),
            payload: envelop_payload.encode_to_vec(),
        };

        // debug
        log::trace!("envelope len: {}", envelope.encoded_len());

        // encode envelope
        let mut envelope_buf = Vec::with_capacity(envelope.encoded_len());
        envelope
            .encode(&mut envelope_buf)
            .expect("Vec<u8> provides capacity as needed");

        // sign message
        if let Ok(signature) = user_account.keys.sign(&envelope_buf) {
            // create container
            let container = proto::Container {
                signature: signature.clone(),
                envelope: Some(envelope),
            };

            // in common message case, save into unconfirmed table
            if is_common_message {
                Self::save_unconfirmed_message(
                    MessagingServiceType::Chat,
                    message_id,
                    receiver,
                    &container,
                    false,
                );
            }

            // schedule message for sending
            Self::schedule_message(
                receiver.clone(),
                container,
                is_common_message,
                false,
                false,
                false,
            );

            // return signature
            Ok(signature)
        } else {
            return Err("messaging signing error".to_string());
        }
    }

    /// pack, sign and schedule a message for sending
    pub fn send_dtn_message(
        user_account: &UserAccount,
        storage_node_id: &PeerId,
        org_container: &proto::Container,
    ) -> Result<Vec<u8>, String> {
        // create Dtn message
        let dtn_payload = proto::EnvelopPayload {
            payload: Some(proto::envelop_payload::Payload::Dtn(
                org_container.encode_to_vec(),
            )),
        };
        let envelope_dtn = proto::Envelope {
            sender_id: user_account.id.to_bytes(),
            receiver_id: storage_node_id.to_bytes(),
            payload: dtn_payload.encode_to_vec(),
        };

        if let Ok(signature_dtn) = user_account.keys.sign(&envelope_dtn.encode_to_vec()) {
            // create dtn container
            let container_dtn = proto::Container {
                signature: signature_dtn.clone(),
                envelope: Some(envelope_dtn),
            };

            // in common message case, save into unconfirmed table
            Self::save_unconfirmed_message(
                MessagingServiceType::Chat,
                &Vec::new(),
                &storage_node_id,
                &container_dtn,
                true,
            );

            // schedule message for sending
            Self::schedule_message(
                storage_node_id.clone(),
                container_dtn,
                true,
                false,
                true,
                true,
            );

            // return signature
            Ok(signature_dtn)
        } else {
            return Err("dtn messaging signing error".to_string());
        }
    }

    /// schedule a message
    ///
    /// schedule a message for sending.
    /// This function adds the message to the ring buffer for sending.
    /// This buffer is checked regularly by libqaul for sending.
    ///
    pub fn schedule_message(
        receiver: PeerId,
        container: proto::Container,
        is_common: bool,
        is_forward: bool,
        scheduled_dtn: bool,
        is_dtn: bool,
    ) {
        #[cfg(emulate)]
        if network_emul::NetworkEmulator::is_lost() {
            log::error!(
                "drop message, signature: {}",
                bs58::encode(container.signature.clone()).into_string()
            );
            return;
        }

        let msg = ScheduledMessage {
            receiver,
            container,
            is_common,
            is_forward,
            scheduled_dtn,
            is_dtn,
        };

        // add it to sending queue
        let mut messaging = MESSAGING.get().write().unwrap();
        messaging.to_send.push_back(msg);
    }

    /// Check Scheduler
    ///
    /// Check if there is a message scheduled for sending.
    ///
    pub fn check_scheduler() -> Option<(PeerId, ConnectionModule, Vec<u8>)> {
        let message_item: Option<ScheduledMessage>;

        // get scheduled messaging buffer
        {
            let mut messaging = MESSAGING.get().write().unwrap();
            message_item = messaging.to_send.pop_front();
        }

        if let Some(message) = message_item {
            // check for route
            if let Some(route) = RoutingTable::get_route_to_user(message.receiver) {
                // update unconfirmed table set scheduled flag.
                Self::on_scheduled_message(&message.container.signature);

                // create binary message
                let data = message.container.encode_to_vec();

                // return information
                return Some((route.node, route.module, data));
            } else {
                // user is offline we schedule through DTN service
                if !message.is_forward
                    && !message.is_dtn
                    && !message.scheduled_dtn
                    && message.is_common
                {
                    // get storage node id
                    if let Ok(my_user_id) =
                        PeerId::from_bytes(&message.container.envelope.as_ref().unwrap().sender_id)
                    {
                        if let Some(storage_node_id) =
                            super::dtn::Dtn::get_storage_user(&my_user_id)
                        {
                            if let Some(user_account) = UserAccounts::get_by_id(my_user_id) {
                                if let Err(_e) = Self::send_dtn_message(
                                    &user_account,
                                    &storage_node_id,
                                    &message.container,
                                ) {
                                    log::error!("DTN scheduling error!");
                                } else {
                                    log::error!("DTN scheduled...");
                                    // update unconfirmed table
                                    Self::on_scheduled_as_dtn_message(&message.container.signature);
                                }
                            }
                        }
                    }
                }
            }
        }

        None
    }

    /// Send a confirmation message for a received message
    pub fn send_confirmation(
        user_id: &PeerId,
        receiver_id: &PeerId,
        signature: &Vec<u8>,
    ) -> Result<Vec<u8>, String> {
        if let Some(user) = UserAccounts::get_by_id(user_id.clone()) {
            // create timestamp
            let timestamp = Timestamp::get_timestamp();

            // pack message
            let send_message = proto::Messaging {
                message: Some(proto::messaging::Message::ConfirmationMessage(
                    proto::Confirmation {
                        signature: signature.clone(),
                        received_at: timestamp,
                    },
                )),
            };

            // encode chat message
            let mut message_buf = Vec::with_capacity(send_message.encoded_len());
            send_message
                .encode(&mut message_buf)
                .expect("Vec<u8> provides capacity as needed");

            // send message via messaging
            let message_id: Vec<u8> = Vec::new();
            Self::pack_and_send_message(
                &user,
                receiver_id,
                message_buf,
                MessagingServiceType::Unconfirmed,
                &message_id,
                false,
            )
        } else {
            return Err("invalid user_id".to_string());
        }
    }

    /// received message from qaul_messaging behaviour
    pub fn received(received: QaulMessagingReceived) {
        // decode message container
        match proto::Container::decode(&received.data[..]) {
            Ok(container) => {
                if let Some(envelope) = container.envelope.clone() {
                    match PeerId::from_bytes(&envelope.receiver_id) {
                        Ok(receiver_id) => {
                            // check if message is local user account
                            match UserAccounts::get_by_id(receiver_id) {
                                // we are the receiving node,
                                // process and save the message
                                Some(user_account) => MessagingProcess::process_received_message(
                                    user_account,
                                    container,
                                ),

                                // schedule it for further sending otherwise
                                None => Self::schedule_message(
                                    receiver_id,
                                    container,
                                    true,
                                    true,
                                    false,
                                    false,
                                ),
                            }
                        }
                        Err(e) => log::error!(
                            "invalid peer ID of message {}: {}",
                            bs58::encode(container.signature).into_string(),
                            e
                        ),
                    }
                }
            }
            Err(e) => log::error!("Messaging container decoding error: {}", e),
        }
    }
}
