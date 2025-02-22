// Copyright (c) 2021 Open Community Project Association https://ocpa.ch
// This software is published under the AGPLv3 license.

//! # Process RPC Messages
//!
//! The RPC messages are defined in the protobuf format.
//! The format is then translated to rust program code.

pub mod debug;
pub mod sys;

use crossbeam_channel::{unbounded, Receiver, Sender, TryRecvError};
use state::Storage;
use std::sync::RwLock;

use prost::Message;

use crate::connections::ble::Ble;
use crate::connections::Connections;
use crate::connections::{internet::Internet, lan::Lan};
use crate::node::user_accounts::UserAccounts;
use crate::node::Node;
use crate::router::users::Users;
use crate::router::Router;
use crate::services::chat::Chat;
use crate::services::chat::ChatFile;
use crate::services::dtn::Dtn;
use crate::services::feed::Feed;
use crate::services::group::Group;
use crate::services::rtc::Rtc;
use debug::Debug;

/// Import protobuf message definition generated by
/// the rust module prost-build.
pub mod proto {
    include!("qaul.rpc.rs");
}
use proto::{Modules, QaulRpc};

// alteratively one could import it directly from the target folder
// pub mod rpc_proto {
//     include!(concat!(env!("OUT_DIR"), "/qaul.rpc.rs"));
// }

/// counter of received messages
/// this is for bug fixing only
pub struct MessageCounter {
    count: i32,
}
/// state of message counter
static EXTERN_SEND_COUNT: Storage<RwLock<MessageCounter>> = Storage::new();

/// receiving end of the mpsc channel
static EXTERN_RECEIVE: Storage<Receiver<Vec<u8>>> = Storage::new();
/// sending end of the mpsc channel
static EXTERN_SEND: Storage<Sender<Vec<u8>>> = Storage::new();
/// sending end of th mpsc channel for libqaul to send
static LIBQAUL_SEND: Storage<Sender<Vec<u8>>> = Storage::new();

/// Handling of RPC messages of libqaul
pub struct Rpc {}

impl Rpc {
    /// Initialize RPC module
    /// Create the sending and receiving channels and put them to state.
    /// Return the receiving channel for libqaul.
    pub fn init() -> Receiver<Vec<u8>> {
        // create channels
        let (libqaul_send, extern_receive) = unbounded();
        let (extern_send, libqaul_receive) = unbounded();

        // save to state
        EXTERN_RECEIVE.set(extern_receive);
        EXTERN_SEND.set(extern_send);
        LIBQAUL_SEND.set(libqaul_send.clone());

        // create bug fixing counter
        let message_counter = MessageCounter { count: 0 };
        EXTERN_SEND_COUNT.set(RwLock::new(message_counter));

        // return libqaul receiving channel
        libqaul_receive
    }

    /// send rpc message from the outside to the inside
    /// of the worker thread of libqaul.
    pub fn send_to_libqaul(binary_message: Vec<u8>) {
        let sender = EXTERN_SEND.get().clone();
        match sender.send(binary_message) {
            Ok(()) => {}
            Err(err) => {
                // log error message
                log::error!("{:?}", err);
            }
        }
    }

    /// check the receiving rpc channel if there
    /// are new messages from inside libqaul for
    /// the outside.
    pub fn receive_from_libqaul() -> Result<Vec<u8>, TryRecvError> {
        let receiver = EXTERN_RECEIVE.get().clone();
        receiver.try_recv()
    }

    /// get the number of messages in the receiving cue
    pub fn receive_from_libqaul_queue_length() -> usize {
        let receiver = EXTERN_RECEIVE.get().clone();
        receiver.len()
    }

    /// send an rpc message from inside libqaul thread
    /// to the extern.
    pub fn send_to_extern(message: Vec<u8>) {
        let sender = LIBQAUL_SEND.get().clone();
        match sender.send(message) {
            Ok(()) => {}
            Err(err) => {
                // log error message
                log::error!("{:?}", err);
            }
        }
    }

    /// Process received binary protobuf encoded RPC message
    ///
    /// This function will decode the message from the binary
    /// protobuf format to rust structures and send it to
    /// the module responsible.
    pub async fn process_received_message(
        data: Vec<u8>,
        lan: Option<&mut Lan>,
        internet: Option<&mut Internet>,
    ) {
        Self::increase_message_counter();

        match QaulRpc::decode(&data[..]) {
            Ok(message) => {
                match Modules::from_i32(message.module) {
                    Some(Modules::Node) => {
                        Self::increase_message_counter();
                        Node::rpc(message.data, lan, internet);
                    }
                    Some(Modules::Rpc) => {
                        log::trace!("Message Modules::Rpc received");
                        // TODO: authorisation
                    }
                    Some(Modules::Useraccounts) => {
                        UserAccounts::rpc(message.data);
                    }
                    Some(Modules::Users) => {
                        Users::rpc(message.data, message.user_id);
                    }
                    Some(Modules::Router) => {
                        Router::rpc(message.data);
                    }
                    Some(Modules::Feed) => {
                        Feed::rpc(message.data, message.user_id, lan, internet);
                    }
                    Some(Modules::Connections) => {
                        Connections::rpc(message.data, internet);
                    }
                    Some(Modules::Ble) => {
                        Ble::rpc(message.data);
                    }
                    Some(Modules::Debug) => {
                        Debug::rpc(message.data, message.user_id);
                    }
                    Some(Modules::Chat) => {
                        Chat::rpc(message.data, message.user_id, lan, internet);
                    }
                    Some(Modules::Chatfile) => {
                        log::trace!("Message Modules::Chatfile received");
                        ChatFile::rpc(message.data, message.user_id).await;
                    }
                    Some(Modules::Group) => {
                        log::trace!("Message Modules::Group received");
                        Group::rpc(message.data, message.user_id, message.request_id);
                    }
                    Some(Modules::Rtc) => {
                        log::trace!("Message Modules::Group received");
                        Rtc::rpc(message.data, message.user_id);
                    }
                    Some(Modules::Dtn) => {
                        log::trace!("Message Modules::Group received");
                        Dtn::rpc(message.data, message.user_id);
                    }
                    Some(Modules::None) => {
                        log::error!("Message Modules::None received");
                    }
                    None => {
                        log::error!("Message module undefined");
                    }
                }
            }
            Err(error) => {
                log::error!("{:?}", error);
            }
        }
    }

    /// sends an RPC message to the outside
    pub fn send_message(data: Vec<u8>, module: i32, request_id: String, user_id: Vec<u8>) {
        // Create RPC message container
        let proto_message = proto::QaulRpc {
            module,
            request_id,
            user_id,
            data,
        };

        // encode message
        let mut buf = Vec::with_capacity(proto_message.encoded_len());
        proto_message
            .encode(&mut buf)
            .expect("Vec<u8> provides capacity as needed");

        // send the message
        Self::send_to_extern(buf);
    }

    /// get message count of all messages sent to libqaul
    ///
    /// This function is for bug fixing only,
    /// it changes and can be removed anytime.
    /// Please don't use it for anything serious.
    pub fn send_rpc_count() -> i32 {
        let counter = EXTERN_SEND_COUNT.get().read().unwrap();
        counter.count
    }

    /// increase message counter by one, of all messages sent to libqaul
    ///
    /// This function is for bug fixing only,
    /// it changes and can be removed anytime.
    /// Please don't use it for anything serious.
    pub fn increase_message_counter() {
        let mut counter = EXTERN_SEND_COUNT.get().write().unwrap();
        counter.count = counter.count + 1;
    }
}
