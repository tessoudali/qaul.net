// Copyright (c) 2021 Open Community Project Association https://ocpa.ch
// This software is published under the AGPLv3 license.

//! Event handling for connection modules

use libp2p::ping::{Event, Failure, Success};
use std::convert::TryFrom;

use qaul_info::QaulInfoEvent;
use qaul_messaging::QaulMessagingEvent;

use crate::connections::ConnectionModule;
use crate::router::{info::RouterInfo, neighbours::Neighbours};
use crate::services::messaging::Messaging;

/// Handle incoming QaulInfo behaviour events
pub fn qaul_info_event(event: QaulInfoEvent, _module: ConnectionModule) {
    match event {
        // received a RoutingInfo message
        QaulInfoEvent::Message(message) => {
            log::trace!(
                "QaulInfoEvent::Message(QaulInfoReceived) from {}",
                message.received_from
            );

            // forward to router
            RouterInfo::received(message);
        }
    }
}

/// Handle incoming QaulMessaging behaviour events
pub fn qaul_messaging_event(event: QaulMessagingEvent, _module: ConnectionModule) {
    match event {
        // received a messaging message
        QaulMessagingEvent::Message(message) => {
            log::trace!(
                "QaulMessagingEvent::Message(QaulMessagingReceived) from {}",
                message.received_from
            );

            // forward to messaging module
            Messaging::received(message);
        }
    }
}

/// Handle incoming ping event
pub fn ping_event(event: Event, module: ConnectionModule) {
    match event {
        Event {
            peer,
            result: Result::Ok(Success::Ping { rtt }),
        } => {
            log::debug!(
                "PingSuccess::Ping: rtt to {} is {} ms",
                peer,
                rtt.as_millis()
            );
            let rtt_micros = u32::try_from(rtt.as_micros());
            match rtt_micros {
                Ok(micros) => Neighbours::update_node(module, peer, micros),
                Err(_) => Neighbours::update_node(module, peer, 4294967295),
            }
        }
        Event {
            peer,
            result: Result::Ok(Success::Pong),
        } => {
            log::debug!("PingSuccess::Pong from {}", peer);
        }
        Event {
            peer,
            result: Result::Err(Failure::Timeout),
        } => {
            log::debug!("PingFailure::Timeout to {}", peer);
        }
        Event {
            peer,
            result: Result::Err(Failure::Other { error }),
        } => {
            log::debug!("PingFailure::Other {} error: {}", peer, error);
        }
        Event {
            peer,
            result: Result::Err(Failure::Unsupported),
        } => {
            log::debug!("PingFailure::Unsupported by peer {}", peer);
        }
    }
}
