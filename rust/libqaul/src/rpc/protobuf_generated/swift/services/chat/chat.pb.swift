// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: services/chat/chat.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// Chat service RPC message container
struct Qaul_Rpc_Chat_Chat {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// message type
  var message: Qaul_Rpc_Chat_Chat.OneOf_Message? = nil

  /// request an overview over the last conversations
  var overviewRequest: Qaul_Rpc_Chat_ChatOverviewRequest {
    get {
      if case .overviewRequest(let v)? = message {return v}
      return Qaul_Rpc_Chat_ChatOverviewRequest()
    }
    set {message = .overviewRequest(newValue)}
  }

  /// contains the overview list
  var overviewList: Qaul_Rpc_Chat_ChatOverviewList {
    get {
      if case .overviewList(let v)? = message {return v}
      return Qaul_Rpc_Chat_ChatOverviewList()
    }
    set {message = .overviewList(newValue)}
  }

  /// request a specific conversation
  var conversationRequest: Qaul_Rpc_Chat_ChatConversationRequest {
    get {
      if case .conversationRequest(let v)? = message {return v}
      return Qaul_Rpc_Chat_ChatConversationRequest()
    }
    set {message = .conversationRequest(newValue)}
  }

  /// list of a chat conversation
  var conversationList: Qaul_Rpc_Chat_ChatConversationList {
    get {
      if case .conversationList(let v)? = message {return v}
      return Qaul_Rpc_Chat_ChatConversationList()
    }
    set {message = .conversationList(newValue)}
  }

  /// send a new chat message
  var send: Qaul_Rpc_Chat_ChatMessageSend {
    get {
      if case .send(let v)? = message {return v}
      return Qaul_Rpc_Chat_ChatMessageSend()
    }
    set {message = .send(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  /// message type
  enum OneOf_Message: Equatable {
    /// request an overview over the last conversations
    case overviewRequest(Qaul_Rpc_Chat_ChatOverviewRequest)
    /// contains the overview list
    case overviewList(Qaul_Rpc_Chat_ChatOverviewList)
    /// request a specific conversation
    case conversationRequest(Qaul_Rpc_Chat_ChatConversationRequest)
    /// list of a chat conversation
    case conversationList(Qaul_Rpc_Chat_ChatConversationList)
    /// send a new chat message
    case send(Qaul_Rpc_Chat_ChatMessageSend)

  #if !swift(>=4.1)
    static func ==(lhs: Qaul_Rpc_Chat_Chat.OneOf_Message, rhs: Qaul_Rpc_Chat_Chat.OneOf_Message) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.overviewRequest, .overviewRequest): return {
        guard case .overviewRequest(let l) = lhs, case .overviewRequest(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.overviewList, .overviewList): return {
        guard case .overviewList(let l) = lhs, case .overviewList(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.conversationRequest, .conversationRequest): return {
        guard case .conversationRequest(let l) = lhs, case .conversationRequest(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.conversationList, .conversationList): return {
        guard case .conversationList(let l) = lhs, case .conversationList(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.send, .send): return {
        guard case .send(let l) = lhs, case .send(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  init() {}
}

/// request for overview list of all conversations
/// this request shall be sent continuously when the view is open
/// 
/// at the moment always the entire list is sent
struct Qaul_Rpc_Chat_ChatOverviewRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// overview list of conversations
/// this can eighter be the entire list or the last updates
struct Qaul_Rpc_Chat_ChatOverviewList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var conversationList: [Qaul_Rpc_Chat_ChatConversation] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// a chat conversation item
struct Qaul_Rpc_Chat_ChatConversation {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// id of the user
  var conversationID: Data = Data()

  /// last message index
  var lastMessageIndex: UInt32 = 0

  /// name of the conversation
  var name: String = String()

  /// time when last message was sent or received
  var lastMessageAt: UInt64 = 0

  /// unread messages
  var unread: Int32 = 0

  /// preview text of the last message
  var content: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// request messages of a specific chat conversation
struct Qaul_Rpc_Chat_ChatConversationRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var conversationID: Data = Data()

  /// send only changes that are newer than the last received
  var lastReceived: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// list of chat messages of a specific conversation
struct Qaul_Rpc_Chat_ChatConversationList {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var conversationID: Data = Data()

  var messageList: [Qaul_Rpc_Chat_ChatMessage] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// a single chat message
struct Qaul_Rpc_Chat_ChatMessage {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// message index
  var index: UInt32 = 0

  /// id of the sending user
  var senderID: Data = Data()

  /// message id
  var messageID: Data = Data()

  /// message status
  /// 0 = nothing
  /// 1 = sent
  /// 2 = received
  var status: Int32 = 0

  /// time when the message was sent
  var sentAt: UInt64 = 0

  /// time when the message was received
  var receivedAt: UInt64 = 0

  /// content of the message
  var content: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// send chat message
struct Qaul_Rpc_Chat_ChatMessageSend {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// conversation id to which this message is sent
  var conversationID: Data = Data()

  /// content of the message
  var content: String = String()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "qaul.rpc.chat"

extension Qaul_Rpc_Chat_Chat: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Chat"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "overview_request"),
    2: .standard(proto: "overview_list"),
    3: .standard(proto: "conversation_request"),
    4: .standard(proto: "conversation_list"),
    5: .same(proto: "send"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try {
        var v: Qaul_Rpc_Chat_ChatOverviewRequest?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .overviewRequest(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .overviewRequest(v)
        }
      }()
      case 2: try {
        var v: Qaul_Rpc_Chat_ChatOverviewList?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .overviewList(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .overviewList(v)
        }
      }()
      case 3: try {
        var v: Qaul_Rpc_Chat_ChatConversationRequest?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .conversationRequest(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .conversationRequest(v)
        }
      }()
      case 4: try {
        var v: Qaul_Rpc_Chat_ChatConversationList?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .conversationList(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .conversationList(v)
        }
      }()
      case 5: try {
        var v: Qaul_Rpc_Chat_ChatMessageSend?
        var hadOneofValue = false
        if let current = self.message {
          hadOneofValue = true
          if case .send(let m) = current {v = m}
        }
        try decoder.decodeSingularMessageField(value: &v)
        if let v = v {
          if hadOneofValue {try decoder.handleConflictingOneOf()}
          self.message = .send(v)
        }
      }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    switch self.message {
    case .overviewRequest?: try {
      guard case .overviewRequest(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    }()
    case .overviewList?: try {
      guard case .overviewList(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    }()
    case .conversationRequest?: try {
      guard case .conversationRequest(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    }()
    case .conversationList?: try {
      guard case .conversationList(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 4)
    }()
    case .send?: try {
      guard case .send(let v)? = self.message else { preconditionFailure() }
      try visitor.visitSingularMessageField(value: v, fieldNumber: 5)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_Chat, rhs: Qaul_Rpc_Chat_Chat) -> Bool {
    if lhs.message != rhs.message {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatOverviewRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatOverviewRequest"
  static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let _ = try decoder.nextFieldNumber() {
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatOverviewRequest, rhs: Qaul_Rpc_Chat_ChatOverviewRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatOverviewList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatOverviewList"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "conversation_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.conversationList) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.conversationList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.conversationList, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatOverviewList, rhs: Qaul_Rpc_Chat_ChatOverviewList) -> Bool {
    if lhs.conversationList != rhs.conversationList {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatConversation: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatConversation"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "conversation_id"),
    2: .standard(proto: "last_message_index"),
    3: .same(proto: "name"),
    4: .standard(proto: "last_message_at"),
    5: .same(proto: "unread"),
    6: .same(proto: "content"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.conversationID) }()
      case 2: try { try decoder.decodeSingularUInt32Field(value: &self.lastMessageIndex) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 4: try { try decoder.decodeSingularUInt64Field(value: &self.lastMessageAt) }()
      case 5: try { try decoder.decodeSingularInt32Field(value: &self.unread) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.content) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.conversationID.isEmpty {
      try visitor.visitSingularBytesField(value: self.conversationID, fieldNumber: 1)
    }
    if self.lastMessageIndex != 0 {
      try visitor.visitSingularUInt32Field(value: self.lastMessageIndex, fieldNumber: 2)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 3)
    }
    if self.lastMessageAt != 0 {
      try visitor.visitSingularUInt64Field(value: self.lastMessageAt, fieldNumber: 4)
    }
    if self.unread != 0 {
      try visitor.visitSingularInt32Field(value: self.unread, fieldNumber: 5)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatConversation, rhs: Qaul_Rpc_Chat_ChatConversation) -> Bool {
    if lhs.conversationID != rhs.conversationID {return false}
    if lhs.lastMessageIndex != rhs.lastMessageIndex {return false}
    if lhs.name != rhs.name {return false}
    if lhs.lastMessageAt != rhs.lastMessageAt {return false}
    if lhs.unread != rhs.unread {return false}
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatConversationRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatConversationRequest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "conversation_id"),
    2: .standard(proto: "last_received"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.conversationID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.lastReceived) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.conversationID.isEmpty {
      try visitor.visitSingularBytesField(value: self.conversationID, fieldNumber: 1)
    }
    if !self.lastReceived.isEmpty {
      try visitor.visitSingularStringField(value: self.lastReceived, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatConversationRequest, rhs: Qaul_Rpc_Chat_ChatConversationRequest) -> Bool {
    if lhs.conversationID != rhs.conversationID {return false}
    if lhs.lastReceived != rhs.lastReceived {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatConversationList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatConversationList"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "conversation_id"),
    2: .standard(proto: "message_list"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.conversationID) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.messageList) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.conversationID.isEmpty {
      try visitor.visitSingularBytesField(value: self.conversationID, fieldNumber: 1)
    }
    if !self.messageList.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.messageList, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatConversationList, rhs: Qaul_Rpc_Chat_ChatConversationList) -> Bool {
    if lhs.conversationID != rhs.conversationID {return false}
    if lhs.messageList != rhs.messageList {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatMessage: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatMessage"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "index"),
    2: .standard(proto: "sender_id"),
    3: .standard(proto: "message_id"),
    4: .same(proto: "status"),
    5: .standard(proto: "sent_at"),
    6: .standard(proto: "received_at"),
    7: .same(proto: "content"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.index) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.senderID) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.messageID) }()
      case 4: try { try decoder.decodeSingularInt32Field(value: &self.status) }()
      case 5: try { try decoder.decodeSingularUInt64Field(value: &self.sentAt) }()
      case 6: try { try decoder.decodeSingularUInt64Field(value: &self.receivedAt) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.content) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.index != 0 {
      try visitor.visitSingularUInt32Field(value: self.index, fieldNumber: 1)
    }
    if !self.senderID.isEmpty {
      try visitor.visitSingularBytesField(value: self.senderID, fieldNumber: 2)
    }
    if !self.messageID.isEmpty {
      try visitor.visitSingularBytesField(value: self.messageID, fieldNumber: 3)
    }
    if self.status != 0 {
      try visitor.visitSingularInt32Field(value: self.status, fieldNumber: 4)
    }
    if self.sentAt != 0 {
      try visitor.visitSingularUInt64Field(value: self.sentAt, fieldNumber: 5)
    }
    if self.receivedAt != 0 {
      try visitor.visitSingularUInt64Field(value: self.receivedAt, fieldNumber: 6)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 7)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatMessage, rhs: Qaul_Rpc_Chat_ChatMessage) -> Bool {
    if lhs.index != rhs.index {return false}
    if lhs.senderID != rhs.senderID {return false}
    if lhs.messageID != rhs.messageID {return false}
    if lhs.status != rhs.status {return false}
    if lhs.sentAt != rhs.sentAt {return false}
    if lhs.receivedAt != rhs.receivedAt {return false}
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Qaul_Rpc_Chat_ChatMessageSend: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChatMessageSend"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "conversation_id"),
    2: .same(proto: "content"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBytesField(value: &self.conversationID) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.content) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.conversationID.isEmpty {
      try visitor.visitSingularBytesField(value: self.conversationID, fieldNumber: 1)
    }
    if !self.content.isEmpty {
      try visitor.visitSingularStringField(value: self.content, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Qaul_Rpc_Chat_ChatMessageSend, rhs: Qaul_Rpc_Chat_ChatMessageSend) -> Bool {
    if lhs.conversationID != rhs.conversationID {return false}
    if lhs.content != rhs.content {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}