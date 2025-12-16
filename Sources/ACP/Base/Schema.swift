import Foundation

/// Capabilities supported by the agent.
///
/// Advertised during initialization to inform the client about
/// available features and content types.
///
/// See protocol docs: [Agent Capabilities](https://agentclientprotocol.com/protocol/initialization#agent-capabilities)
public struct AgentCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Whether the agent supports `session/load`.
  public let loadSession: Bool?
  /// MCP capabilities supported by the agent.
  public let mcpCapabilities: McpCapabilities?
  /// Prompt capabilities supported by the agent.
  public let promptCapabilities: PromptCapabilities?
  public let sessionCapabilities: SessionCapabilities?

  public init(
    _meta: [String: AnyCodable]? = nil, loadSession: Bool? = nil,
    mcpCapabilities: McpCapabilities? = nil, promptCapabilities: PromptCapabilities? = nil,
    sessionCapabilities: SessionCapabilities? = nil
  ) {
    self._meta = _meta
    self.loadSession = loadSession
    self.mcpCapabilities = mcpCapabilities
    self.promptCapabilities = promptCapabilities
    self.sessionCapabilities = sessionCapabilities
  }
}

public struct AgentNotification: Codable, Sendable {
  public let method: String
  public let params: AgentNotificationParams?

  public init(method: String, params: AgentNotificationParams? = nil) {
    self.method = method
    self.params = params
  }
}

public struct AgentRequest: Codable, Sendable {
  public let id: RequestId
  public let method: String
  public let params: AgentRequestParams?

  public init(id: RequestId, method: String, params: AgentRequestParams? = nil) {
    self.id = id
    self.method = method
    self.params = params
  }
}

public struct AgentResponseOption1: Codable, Sendable {
  public let id: RequestId
  /// All possible responses that an agent can send to a client.
  ///
  /// This enum is used internally for routing RPC responses. You typically won't need
  /// to use this directly - the responses are handled automatically by the connection.
  ///
  /// These are responses to the corresponding `ClientRequest` variants.
  public let result: ResultOption

  public init(id: RequestId, result: ResultOption) {
    self.id = id
    self.result = result
  }
}

public struct AgentResponseOption2: Codable, Sendable {
  public let error: JSONRPCError
  public let id: RequestId

  public init(error: JSONRPCError, id: RequestId) {
    self.error = error
    self.id = id
  }
}

public enum AgentResponse: Codable, Sendable {
  case agentResponseOption1(AgentResponseOption1)
  case agentResponseOption2(AgentResponseOption2)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(AgentResponseOption1.self) {
      self = .agentResponseOption1(value)
      return
    }
    if let value = try? container.decode(AgentResponseOption2.self) {
      self = .agentResponseOption2(value)
      return
    }
    throw DecodingError.typeMismatch(
      AgentResponse.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for AgentResponse"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .agentResponseOption1(let value):
      try container.encode(value)
    case .agentResponseOption2(let value):
      try container.encode(value)
    }
  }
}

/// Optional annotations for the client. The client can use annotations to inform how objects are used or displayed
public struct Annotations: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let audience: [Role]?
  public let lastModified: String?
  public let priority: Double?

  public init(
    _meta: [String: AnyCodable]? = nil, audience: [Role]? = nil, lastModified: String? = nil,
    priority: Double? = nil
  ) {
    self._meta = _meta
    self.audience = audience
    self.lastModified = lastModified
    self.priority = priority
  }
}

/// Audio provided to or from an LLM.
public struct AudioContent: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let annotations: Annotations?
  public let data: String
  public let mimeType: String

  public init(
    _meta: [String: AnyCodable]? = nil, annotations: Annotations? = nil, data: String,
    mimeType: String
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.data = data
    self.mimeType = mimeType
  }
}

/// Describes an available authentication method.
public struct AuthMethod: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Optional description providing more details about this authentication method.
  public let description: String?
  /// Unique identifier for this authentication method.
  public let id: String
  /// Human-readable name of the authentication method.
  public let name: String

  public init(
    _meta: [String: AnyCodable]? = nil, description: String? = nil, id: String, name: String
  ) {
    self._meta = _meta
    self.description = description
    self.id = id
    self.name = name
  }
}

/// Request parameters for the authenticate method.
///
/// Specifies which authentication method to use.
public struct AuthenticateRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the authentication method to use.
  /// Must be one of the methods advertised in the initialize response.
  public let methodId: String

  public init(_meta: [String: AnyCodable]? = nil, methodId: String) {
    self._meta = _meta
    self.methodId = methodId
  }
}

/// Response to the `authenticate` method.
public struct AuthenticateResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

/// Information about a command.
public struct AvailableCommand: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Human-readable description of what the command does.
  public let description: String
  /// Input for the command if required
  public let input: AvailableCommandInput?
  /// Command name (e.g., `create_plan`, `research_codebase`).
  public let name: String

  public init(
    _meta: [String: AnyCodable]? = nil, description: String, input: AvailableCommandInput? = nil,
    name: String
  ) {
    self._meta = _meta
    self.description = description
    self.input = input
    self.name = name
  }
}

/// All text that was typed after the command name is provided as input.
public struct UnstructuredCommandInput: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// A hint to display when the input hasn't been provided yet
  public let hint: String

  public init(_meta: [String: AnyCodable]? = nil, hint: String) {
    self._meta = _meta
    self.hint = hint
  }
}

public enum AvailableCommandInput: Codable, Sendable {
  case unstructuredCommandInput(UnstructuredCommandInput)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(UnstructuredCommandInput.self) {
      self = .unstructuredCommandInput(value)
      return
    }
    throw DecodingError.typeMismatch(
      AvailableCommandInput.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No matching type for AvailableCommandInput"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .unstructuredCommandInput(let value):
      try container.encode(value)
    }
  }
}

/// Available commands are ready or have changed
public struct AvailableCommandsUpdate: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Commands the agent can execute
  public let availableCommands: [AvailableCommand]

  public init(_meta: [String: AnyCodable]? = nil, availableCommands: [AvailableCommand]) {
    self._meta = _meta
    self.availableCommands = availableCommands
  }
}

/// Binary resource contents.
public struct BlobResourceContents: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let blob: String
  public let mimeType: String?
  public let uri: String

  public init(
    _meta: [String: AnyCodable]? = nil, blob: String, mimeType: String? = nil, uri: String
  ) {
    self._meta = _meta
    self.blob = blob
    self.mimeType = mimeType
    self.uri = uri
  }
}

/// Notification to cancel ongoing operations for a session.
///
/// See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/prompt-turn#cancellation)
public struct CancelNotification: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the session to cancel operations for.
  public let sessionId: SessionId

  public init(_meta: [String: AnyCodable]? = nil, sessionId: SessionId) {
    self._meta = _meta
    self.sessionId = sessionId
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Notification to cancel an ongoing request.
///
/// See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/cancellation)
public struct CancelRequestNotification: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the request to cancel.
  public let requestId: RequestId

  public init(_meta: [String: AnyCodable]? = nil, requestId: RequestId) {
    self._meta = _meta
    self.requestId = requestId
  }
}

/// Capabilities supported by the client.
///
/// Advertised during initialization to inform the agent about
/// available features and methods.
///
/// See protocol docs: [Client Capabilities](https://agentclientprotocol.com/protocol/initialization#client-capabilities)
public struct ClientCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// File system capabilities supported by the client.
  /// Determines which file operations the agent can request.
  public let fs: FileSystemCapability?
  /// Whether the Client support all `terminal/*` methods.
  public let terminal: Bool?

  public init(
    _meta: [String: AnyCodable]? = nil, fs: FileSystemCapability? = nil, terminal: Bool? = nil
  ) {
    self._meta = _meta
    self.fs = fs
    self.terminal = terminal
  }
}

public struct ClientNotification: Codable, Sendable {
  public let method: String
  public let params: ClientNotificationParams?

  public init(method: String, params: ClientNotificationParams? = nil) {
    self.method = method
    self.params = params
  }
}

public struct ClientRequest: Codable, Sendable {
  public let id: RequestId
  public let method: String
  public let params: ClientRequestParams?

  public init(id: RequestId, method: String, params: ClientRequestParams? = nil) {
    self.id = id
    self.method = method
    self.params = params
  }
}

public struct ClientResponseOption1: Codable, Sendable {
  public let id: RequestId
  /// All possible responses that a client can send to an agent.
  ///
  /// This enum is used internally for routing RPC responses. You typically won't need
  /// to use this directly - the responses are handled automatically by the connection.
  ///
  /// These are responses to the corresponding `AgentRequest` variants.
  public let result: ResultOption

  public init(id: RequestId, result: ResultOption) {
    self.id = id
    self.result = result
  }
}

public struct ClientResponseOption2: Codable, Sendable {
  public let error: JSONRPCError
  public let id: RequestId

  public init(error: JSONRPCError, id: RequestId) {
    self.error = error
    self.id = id
  }
}

public enum ClientResponse: Codable, Sendable {
  case clientResponseOption1(ClientResponseOption1)
  case clientResponseOption2(ClientResponseOption2)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(ClientResponseOption1.self) {
      self = .clientResponseOption1(value)
      return
    }
    if let value = try? container.decode(ClientResponseOption2.self) {
      self = .clientResponseOption2(value)
      return
    }
    throw DecodingError.typeMismatch(
      ClientResponse.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for ClientResponse"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .clientResponseOption1(let value):
      try container.encode(value)
    case .clientResponseOption2(let value):
      try container.encode(value)
    }
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Session configuration options have been updated.
public struct ConfigOptionUpdate: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The full set of configuration options and their current values.
  public let configOptions: [SessionConfigOption]

  public init(_meta: [String: AnyCodable]? = nil, configOptions: [SessionConfigOption]) {
    self._meta = _meta
    self.configOptions = configOptions
  }
}

/// Standard content block (text, images, resources).
public struct Content: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The actual content block.
  public let content: ContentBlock

  public init(_meta: [String: AnyCodable]? = nil, content: ContentBlock) {
    self._meta = _meta
    self.content = content
  }
}

/// Text provided to or from an LLM.
public struct TextContent: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let annotations: Annotations?
  public let text: String

  public init(_meta: [String: AnyCodable]? = nil, annotations: Annotations? = nil, text: String) {
    self._meta = _meta
    self.annotations = annotations
    self.text = text
  }
}

/// An image provided to or from an LLM.
public struct ImageContent: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let annotations: Annotations?
  public let data: String
  public let mimeType: String
  public let uri: String?

  public init(
    _meta: [String: AnyCodable]? = nil, annotations: Annotations? = nil, data: String,
    mimeType: String, uri: String? = nil
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.data = data
    self.mimeType = mimeType
    self.uri = uri
  }
}

/// A resource that the server is capable of reading, included in a prompt or tool call result.
public struct ResourceLink: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let annotations: Annotations?
  public let description: String?
  public let mimeType: String?
  public let name: String
  public let size: Int?
  public let title: String?
  public let uri: String

  public init(
    _meta: [String: AnyCodable]? = nil, annotations: Annotations? = nil, description: String? = nil,
    mimeType: String? = nil, name: String, size: Int? = nil, title: String? = nil, uri: String
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.description = description
    self.mimeType = mimeType
    self.name = name
    self.size = size
    self.title = title
    self.uri = uri
  }
}

/// The contents of a resource, embedded into a prompt or tool call result.
public struct EmbeddedResource: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let annotations: Annotations?
  public let resource: EmbeddedResourceResource

  public init(
    _meta: [String: AnyCodable]? = nil, annotations: Annotations? = nil,
    resource: EmbeddedResourceResource
  ) {
    self._meta = _meta
    self.annotations = annotations
    self.resource = resource
  }
}

public enum ContentBlock: Codable, Sendable {
  case text(TextContent)
  case image(ImageContent)
  case audio(AudioContent)
  case resource_link(ResourceLink)
  case resource(EmbeddedResource)

  public init(from decoder: Decoder) throws {
    if let key = _DiscriminatorCodingKey(stringValue: "type"),
      let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
      let raw = try? container.decode(String.self, forKey: key)
    {
      switch raw {
      case "text":
        if let value = try? TextContent(from: decoder) {
          self = .text(value)
          return
        }
      case "image":
        if let value = try? ImageContent(from: decoder) {
          self = .image(value)
          return
        }
      case "audio":
        if let value = try? AudioContent(from: decoder) {
          self = .audio(value)
          return
        }
      case "resource_link":
        if let value = try? ResourceLink(from: decoder) {
          self = .resource_link(value)
          return
        }
      case "resource":
        if let value = try? EmbeddedResource(from: decoder) {
          self = .resource(value)
          return
        }
      default:
        break
      }
    }
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(TextContent.self) {
      self = .text(value)
      return
    }
    if let value = try? container.decode(ImageContent.self) {
      self = .image(value)
      return
    }
    if let value = try? container.decode(AudioContent.self) {
      self = .audio(value)
      return
    }
    if let value = try? container.decode(ResourceLink.self) {
      self = .resource_link(value)
      return
    }
    if let value = try? container.decode(EmbeddedResource.self) {
      self = .resource(value)
      return
    }
    throw DecodingError.typeMismatch(
      ContentBlock.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for ContentBlock"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .text(let value):
      try container.encode(value)
    case .image(let value):
      try container.encode(value)
    case .audio(let value):
      try container.encode(value)
    case .resource_link(let value):
      try container.encode(value)
    case .resource(let value):
      try container.encode(value)
    }
  }
}

/// A streamed item of content
public struct ContentChunk: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// A single item of content
  public let content: ContentBlock

  public init(_meta: [String: AnyCodable]? = nil, content: ContentBlock) {
    self._meta = _meta
    self.content = content
  }
}

/// Request to create a new terminal and execute a command.
public struct CreateTerminalRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Array of command arguments.
  public let args: [String]?
  /// The command to execute.
  public let command: String
  /// Working directory for the command (absolute path).
  public let cwd: String?
  /// Environment variables for the command.
  public let env: [EnvVariable]?
  /// Maximum number of output bytes to retain.
  ///
  /// When the limit is exceeded, the Client truncates from the beginning of the output
  /// to stay within the limit.
  ///
  /// The Client MUST ensure truncation happens at a character boundary to maintain valid
  /// string output, even if this means the retained output is slightly less than the
  /// specified limit.
  public let outputByteLimit: Int?
  /// The session ID for this request.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, args: [String]? = nil, command: String, cwd: String? = nil,
    env: [EnvVariable]? = nil, outputByteLimit: Int? = nil, sessionId: SessionId
  ) {
    self._meta = _meta
    self.args = args
    self.command = command
    self.cwd = cwd
    self.env = env
    self.outputByteLimit = outputByteLimit
    self.sessionId = sessionId
  }
}

/// Response containing the ID of the created terminal.
public struct CreateTerminalResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The unique identifier for the created terminal.
  public let terminalId: String

  public init(_meta: [String: AnyCodable]? = nil, terminalId: String) {
    self._meta = _meta
    self.terminalId = terminalId
  }
}

/// The current mode of the session has changed
///
/// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
public struct CurrentModeUpdate: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the current mode
  public let currentModeId: SessionModeId

  public init(_meta: [String: AnyCodable]? = nil, currentModeId: SessionModeId) {
    self._meta = _meta
    self.currentModeId = currentModeId
  }
}

/// A diff representing file modifications.
///
/// Shows changes to files in a format suitable for display in the client UI.
///
/// See protocol docs: [Content](https://agentclientprotocol.com/protocol/tool-calls#content)
public struct Diff: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The new content after modification.
  public let newText: String
  /// The original content (None for new files).
  public let oldText: String?
  /// The file path being modified.
  public let path: String

  public init(
    _meta: [String: AnyCodable]? = nil, newText: String, oldText: String? = nil, path: String
  ) {
    self._meta = _meta
    self.newText = newText
    self.oldText = oldText
    self.path = path
  }
}

/// Text-based resource contents.
public struct TextResourceContents: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let mimeType: String?
  public let text: String
  public let uri: String

  public init(
    _meta: [String: AnyCodable]? = nil, mimeType: String? = nil, text: String, uri: String
  ) {
    self._meta = _meta
    self.mimeType = mimeType
    self.text = text
    self.uri = uri
  }
}

public enum EmbeddedResourceResource: Codable, Sendable {
  case textResourceContents(TextResourceContents)
  case blobResourceContents(BlobResourceContents)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(TextResourceContents.self) {
      self = .textResourceContents(value)
      return
    }
    if let value = try? container.decode(BlobResourceContents.self) {
      self = .blobResourceContents(value)
      return
    }
    throw DecodingError.typeMismatch(
      EmbeddedResourceResource.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No matching type for EmbeddedResourceResource"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .textResourceContents(let value):
      try container.encode(value)
    case .blobResourceContents(let value):
      try container.encode(value)
    }
  }
}

/// An environment variable to set when launching an MCP server.
public struct EnvVariable: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The name of the environment variable.
  public let name: String
  /// The value to set for the environment variable.
  public let value: String

  public init(_meta: [String: AnyCodable]? = nil, name: String, value: String) {
    self._meta = _meta
    self.name = name
    self.value = value
  }
}

/// JSON-RPC error object.
///
/// Represents an error that occurred during method execution, following the
/// JSON-RPC 2.0 error object specification with optional additional data.
///
/// See protocol docs: [JSON-RPC Error Object](https://www.jsonrpc.org/specification#error_object)
public struct JSONRPCError: Codable, Sendable {
  /// A number indicating the error type that occurred.
  /// This must be an integer as defined in the JSON-RPC specification.
  public let code: ErrorCode
  /// Optional primitive or structured value that contains additional information about the error.
  /// This may include debugging information or context-specific details.
  public let data: AnyCodable?
  /// A string providing a short description of the error.
  /// The message should be limited to a concise single sentence.
  public let message: String

  public init(code: ErrorCode, data: AnyCodable? = nil, message: String) {
    self.code = code
    self.data = data
    self.message = message
  }
}

public typealias ErrorCode = AnyCodable

/// Allows the Agent to send an arbitrary notification that is not part of the ACP spec.
/// Extension notifications provide a way to send one-way messages for custom functionality
/// while maintaining protocol compatibility.
///
/// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
public struct ExtNotification: Codable, Sendable {
}

/// Allows for sending an arbitrary request that is not part of the ACP spec.
/// Extension methods provide a way to add custom functionality while maintaining
/// protocol compatibility.
///
/// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
public struct ExtRequest: Codable, Sendable {
}

/// Allows for sending an arbitrary response to an [`ExtRequest`] that is not part of the ACP spec.
/// Extension methods provide a way to add custom functionality while maintaining
/// protocol compatibility.
///
/// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
public struct ExtResponse: Codable, Sendable {
}

/// Filesystem capabilities supported by the client.
/// File system capabilities that a client may support.
///
/// See protocol docs: [FileSystem](https://agentclientprotocol.com/protocol/initialization#filesystem)
public struct FileSystemCapability: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Whether the Client supports `fs/read_text_file` requests.
  public let readTextFile: Bool?
  /// Whether the Client supports `fs/write_text_file` requests.
  public let writeTextFile: Bool?

  public init(
    _meta: [String: AnyCodable]? = nil, readTextFile: Bool? = nil, writeTextFile: Bool? = nil
  ) {
    self._meta = _meta
    self.readTextFile = readTextFile
    self.writeTextFile = writeTextFile
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Request parameters for forking an existing session.
///
/// Creates a new session based on the context of an existing one, allowing
/// operations like generating summaries without affecting the original session's history.
///
/// Only available if the Agent supports the `session.fork` capability.
public struct ForkSessionRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The working directory for this session.
  public let cwd: String
  /// List of MCP servers to connect to for this session.
  public let mcpServers: [McpServer]?
  /// The ID of the session to fork.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, cwd: String, mcpServers: [McpServer]? = nil,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.cwd = cwd
    self.mcpServers = mcpServers
    self.sessionId = sessionId
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Response from forking an existing session.
public struct ForkSessionResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial session configuration options if supported by the Agent.
  public let configOptions: [SessionConfigOption]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial model state if supported by the Agent
  public let models: SessionModelState?
  /// Initial mode state if supported by the Agent
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  public let modes: SessionModeState?
  /// Unique identifier for the newly created forked session.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, configOptions: [SessionConfigOption]? = nil,
    models: SessionModelState? = nil, modes: SessionModeState? = nil, sessionId: SessionId
  ) {
    self._meta = _meta
    self.configOptions = configOptions
    self.models = models
    self.modes = modes
    self.sessionId = sessionId
  }
}

/// An HTTP header to set when making requests to the MCP server.
public struct HttpHeader: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The name of the HTTP header.
  public let name: String
  /// The value to set for the HTTP header.
  public let value: String

  public init(_meta: [String: AnyCodable]? = nil, name: String, value: String) {
    self._meta = _meta
    self.name = name
    self.value = value
  }
}

/// Metadata about the implementation of the client or agent.
/// Describes the name and version of an MCP implementation, with an optional
/// title for UI representation.
public struct Implementation: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Intended for programmatic or logical use, but can be used as a display
  /// name fallback if title isn’t present.
  public let name: String
  /// Intended for UI and end-user contexts — optimized to be human-readable
  /// and easily understood.
  ///
  /// If not provided, the name should be used for display.
  public let title: String?
  /// Version of the implementation. Can be displayed to the user or used
  /// for debugging or metrics purposes. (e.g. "1.0.0").
  public let version: String

  public init(
    _meta: [String: AnyCodable]? = nil, name: String, title: String? = nil, version: String
  ) {
    self._meta = _meta
    self.name = name
    self.title = title
    self.version = version
  }
}

/// Request parameters for the initialize method.
///
/// Sent by the client to establish connection and negotiate capabilities.
///
/// See protocol docs: [Initialization](https://agentclientprotocol.com/protocol/initialization)
public struct InitializeRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Capabilities supported by the client.
  public let clientCapabilities: ClientCapabilities?
  /// Information about the Client name and version sent to the Agent.
  ///
  /// Note: in future versions of the protocol, this will be required.
  public let clientInfo: Implementation?
  /// The latest protocol version supported by the client.
  public let protocolVersion: ProtocolVersion

  public init(
    _meta: [String: AnyCodable]? = nil, clientCapabilities: ClientCapabilities? = nil,
    clientInfo: Implementation? = nil, protocolVersion: ProtocolVersion
  ) {
    self._meta = _meta
    self.clientCapabilities = clientCapabilities
    self.clientInfo = clientInfo
    self.protocolVersion = protocolVersion
  }
}

/// Response to the `initialize` method.
///
/// Contains the negotiated protocol version and agent capabilities.
///
/// See protocol docs: [Initialization](https://agentclientprotocol.com/protocol/initialization)
public struct InitializeResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Capabilities supported by the agent.
  public let agentCapabilities: AgentCapabilities?
  /// Information about the Agent name and version sent to the Client.
  ///
  /// Note: in future versions of the protocol, this will be required.
  public let agentInfo: Implementation?
  /// Authentication methods supported by the agent.
  public let authMethods: [AuthMethod]?
  /// The protocol version the client specified if supported by the agent,
  /// or the latest protocol version supported by the agent.
  ///
  /// The client should disconnect, if it doesn't support this version.
  public let protocolVersion: ProtocolVersion

  public init(
    _meta: [String: AnyCodable]? = nil, agentCapabilities: AgentCapabilities? = nil,
    agentInfo: Implementation? = nil, authMethods: [AuthMethod]? = nil,
    protocolVersion: ProtocolVersion
  ) {
    self._meta = _meta
    self.agentCapabilities = agentCapabilities
    self.agentInfo = agentInfo
    self.authMethods = authMethods
    self.protocolVersion = protocolVersion
  }
}

/// Request to kill a terminal command without releasing the terminal.
public struct KillTerminalCommandRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The session ID for this request.
  public let sessionId: SessionId
  /// The ID of the terminal to kill.
  public let terminalId: String

  public init(_meta: [String: AnyCodable]? = nil, sessionId: SessionId, terminalId: String) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response to terminal/kill command method
public struct KillTerminalCommandResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Request parameters for listing existing sessions.
///
/// Only available if the Agent supports the `listSessions` capability.
public struct ListSessionsRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Opaque cursor token from a previous response's nextCursor field for cursor-based pagination
  public let cursor: String?
  /// Filter sessions by working directory. Must be an absolute path.
  public let cwd: String?

  public init(_meta: [String: AnyCodable]? = nil, cursor: String? = nil, cwd: String? = nil) {
    self._meta = _meta
    self.cursor = cursor
    self.cwd = cwd
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Response from listing sessions.
public struct ListSessionsResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Opaque cursor token. If present, pass this in the next request's cursor parameter
  /// to fetch the next page. If absent, there are no more results.
  public let nextCursor: String?
  /// Array of session information objects
  public let sessions: [SessionInfo]

  public init(
    _meta: [String: AnyCodable]? = nil, nextCursor: String? = nil, sessions: [SessionInfo]
  ) {
    self._meta = _meta
    self.nextCursor = nextCursor
    self.sessions = sessions
  }
}

/// Request parameters for loading an existing session.
///
/// Only available if the Agent supports the `loadSession` capability.
///
/// See protocol docs: [Loading Sessions](https://agentclientprotocol.com/protocol/session-setup#loading-sessions)
public struct LoadSessionRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The working directory for this session.
  public let cwd: String
  /// List of MCP servers to connect to for this session.
  public let mcpServers: [McpServer]
  /// The ID of the session to load.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, cwd: String, mcpServers: [McpServer], sessionId: SessionId
  ) {
    self._meta = _meta
    self.cwd = cwd
    self.mcpServers = mcpServers
    self.sessionId = sessionId
  }
}

/// Response from loading an existing session.
public struct LoadSessionResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial session configuration options if supported by the Agent.
  public let configOptions: [SessionConfigOption]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial model state if supported by the Agent
  public let models: SessionModelState?
  /// Initial mode state if supported by the Agent
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  public let modes: SessionModeState?

  public init(
    _meta: [String: AnyCodable]? = nil, configOptions: [SessionConfigOption]? = nil,
    models: SessionModelState? = nil, modes: SessionModeState? = nil
  ) {
    self._meta = _meta
    self.configOptions = configOptions
    self.models = models
    self.modes = modes
  }
}

/// MCP capabilities supported by the agent
public struct McpCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Agent supports [`McpServer::Http`].
  public let http: Bool?
  /// Agent supports [`McpServer::Sse`].
  public let sse: Bool?

  public init(_meta: [String: AnyCodable]? = nil, http: Bool? = nil, sse: Bool? = nil) {
    self._meta = _meta
    self.http = http
    self.sse = sse
  }
}

/// HTTP transport configuration for MCP.
public struct McpServerHttp: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// HTTP headers to set when making requests to the MCP server.
  public let headers: [HttpHeader]
  /// Human-readable name identifying this MCP server.
  public let name: String
  /// URL to the MCP server.
  public let url: String

  public init(_meta: [String: AnyCodable]? = nil, headers: [HttpHeader], name: String, url: String)
  {
    self._meta = _meta
    self.headers = headers
    self.name = name
    self.url = url
  }
}

/// SSE transport configuration for MCP.
public struct McpServerSse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// HTTP headers to set when making requests to the MCP server.
  public let headers: [HttpHeader]
  /// Human-readable name identifying this MCP server.
  public let name: String
  /// URL to the MCP server.
  public let url: String

  public init(_meta: [String: AnyCodable]? = nil, headers: [HttpHeader], name: String, url: String)
  {
    self._meta = _meta
    self.headers = headers
    self.name = name
    self.url = url
  }
}

/// Stdio transport configuration for MCP.
public struct McpServerStdio: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Command-line arguments to pass to the MCP server.
  public let args: [String]
  /// Path to the MCP server executable.
  public let command: String
  /// Environment variables to set when launching the MCP server.
  public let env: [EnvVariable]
  /// Human-readable name identifying this MCP server.
  public let name: String

  public init(
    _meta: [String: AnyCodable]? = nil, args: [String], command: String, env: [EnvVariable],
    name: String
  ) {
    self._meta = _meta
    self.args = args
    self.command = command
    self.env = env
    self.name = name
  }
}

public enum McpServer: Codable, Sendable {
  case http(McpServerHttp)
  case sse(McpServerSse)
  case mcpServerStdio(McpServerStdio)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(McpServerHttp.self) {
      self = .http(value)
      return
    }
    if let value = try? container.decode(McpServerSse.self) {
      self = .sse(value)
      return
    }
    if let value = try? container.decode(McpServerStdio.self) {
      self = .mcpServerStdio(value)
      return
    }
    throw DecodingError.typeMismatch(
      McpServer.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for McpServer"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .http(let value):
      try container.encode(value)
    case .sse(let value):
      try container.encode(value)
    case .mcpServerStdio(let value):
      try container.encode(value)
    }
  }
}

public typealias ModelId = String

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Information about a selectable model.
public struct ModelInfo: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Optional description of the model.
  public let description: String?
  /// Unique identifier for the model.
  public let modelId: ModelId
  /// Human-readable name of the model.
  public let name: String

  public init(
    _meta: [String: AnyCodable]? = nil, description: String? = nil, modelId: ModelId, name: String
  ) {
    self._meta = _meta
    self.description = description
    self.modelId = modelId
    self.name = name
  }
}

/// Request parameters for creating a new session.
///
/// See protocol docs: [Creating a Session](https://agentclientprotocol.com/protocol/session-setup#creating-a-session)
public struct NewSessionRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The working directory for this session. Must be an absolute path.
  public let cwd: String
  /// List of MCP (Model Context Protocol) servers the agent should connect to.
  public let mcpServers: [McpServer]

  public init(_meta: [String: AnyCodable]? = nil, cwd: String, mcpServers: [McpServer]) {
    self._meta = _meta
    self.cwd = cwd
    self.mcpServers = mcpServers
  }
}

/// Response from creating a new session.
///
/// See protocol docs: [Creating a Session](https://agentclientprotocol.com/protocol/session-setup#creating-a-session)
public struct NewSessionResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial session configuration options if supported by the Agent.
  public let configOptions: [SessionConfigOption]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial model state if supported by the Agent
  public let models: SessionModelState?
  /// Initial mode state if supported by the Agent
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  public let modes: SessionModeState?
  /// Unique identifier for the created session.
  ///
  /// Used in all subsequent requests for this conversation.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, configOptions: [SessionConfigOption]? = nil,
    models: SessionModelState? = nil, modes: SessionModeState? = nil, sessionId: SessionId
  ) {
    self._meta = _meta
    self.configOptions = configOptions
    self.models = models
    self.modes = modes
    self.sessionId = sessionId
  }
}

/// An option presented to the user when requesting permission.
public struct PermissionOption: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Hint about the nature of this permission option.
  public let kind: PermissionOptionKind
  /// Human-readable label to display to the user.
  public let name: String
  /// Unique identifier for this permission option.
  public let optionId: PermissionOptionId

  public init(
    _meta: [String: AnyCodable]? = nil, kind: PermissionOptionKind, name: String,
    optionId: PermissionOptionId
  ) {
    self._meta = _meta
    self.kind = kind
    self.name = name
    self.optionId = optionId
  }
}

public typealias PermissionOptionId = String

public enum PermissionOptionKind: String, Codable, Sendable {
  case allow_once = "allow_once"
  case allow_always = "allow_always"
  case reject_once = "reject_once"
  case reject_always = "reject_always"
}

/// An execution plan for accomplishing complex tasks.
///
/// Plans consist of multiple entries representing individual tasks or goals.
/// Agents report plans to clients to provide visibility into their execution strategy.
/// Plans can evolve during execution as the agent discovers new requirements or completes tasks.
///
/// See protocol docs: [Agent Plan](https://agentclientprotocol.com/protocol/agent-plan)
public struct Plan: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The list of tasks to be accomplished.
  ///
  /// When updating a plan, the agent must send a complete list of all entries
  /// with their current status. The client replaces the entire plan with each update.
  public let entries: [PlanEntry]

  public init(_meta: [String: AnyCodable]? = nil, entries: [PlanEntry]) {
    self._meta = _meta
    self.entries = entries
  }
}

/// A single entry in the execution plan.
///
/// Represents a task or goal that the assistant intends to accomplish
/// as part of fulfilling the user's request.
/// See protocol docs: [Plan Entries](https://agentclientprotocol.com/protocol/agent-plan#plan-entries)
public struct PlanEntry: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Human-readable description of what this task aims to accomplish.
  public let content: String
  /// The relative importance of this task.
  /// Used to indicate which tasks are most critical to the overall goal.
  public let priority: PlanEntryPriority
  /// Current execution status of this task.
  public let status: PlanEntryStatus

  public init(
    _meta: [String: AnyCodable]? = nil, content: String, priority: PlanEntryPriority,
    status: PlanEntryStatus
  ) {
    self._meta = _meta
    self.content = content
    self.priority = priority
    self.status = status
  }
}

public enum PlanEntryPriority: String, Codable, Sendable {
  case high = "high"
  case medium = "medium"
  case low = "low"
}

public enum PlanEntryStatus: String, Codable, Sendable {
  case pending = "pending"
  case in_progress = "in_progress"
  case completed = "completed"
}

/// Prompt capabilities supported by the agent in `session/prompt` requests.
///
/// Baseline agent functionality requires support for [`ContentBlock::Text`]
/// and [`ContentBlock::ResourceLink`] in prompt requests.
///
/// Other variants must be explicitly opted in to.
/// Capabilities for different types of content in prompt requests.
///
/// Indicates which content types beyond the baseline (text and resource links)
/// the agent can process.
///
/// See protocol docs: [Prompt Capabilities](https://agentclientprotocol.com/protocol/initialization#prompt-capabilities)
public struct PromptCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Agent supports [`ContentBlock::Audio`].
  public let audio: Bool?
  /// Agent supports embedded context in `session/prompt` requests.
  ///
  /// When enabled, the Client is allowed to include [`ContentBlock::Resource`]
  /// in prompt requests for pieces of context that are referenced in the message.
  public let embeddedContext: Bool?
  /// Agent supports [`ContentBlock::Image`].
  public let image: Bool?

  public init(
    _meta: [String: AnyCodable]? = nil, audio: Bool? = nil, embeddedContext: Bool? = nil,
    image: Bool? = nil
  ) {
    self._meta = _meta
    self.audio = audio
    self.embeddedContext = embeddedContext
    self.image = image
  }
}

/// Request parameters for sending a user prompt to the agent.
///
/// Contains the user's message and any additional context.
///
/// See protocol docs: [User Message](https://agentclientprotocol.com/protocol/prompt-turn#1-user-message)
public struct PromptRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The blocks of content that compose the user's message.
  ///
  /// As a baseline, the Agent MUST support [`ContentBlock::Text`] and [`ContentBlock::ResourceLink`],
  /// while other variants are optionally enabled via [`PromptCapabilities`].
  ///
  /// The Client MUST adapt its interface according to [`PromptCapabilities`].
  ///
  /// The client MAY include referenced pieces of context as either
  /// [`ContentBlock::Resource`] or [`ContentBlock::ResourceLink`].
  ///
  /// When available, [`ContentBlock::Resource`] is preferred
  /// as it avoids extra round-trips and allows the message to include
  /// pieces of context from sources the agent may not have access to.
  public let prompt: [ContentBlock]
  /// The ID of the session to send this user message to
  public let sessionId: SessionId

  public init(_meta: [String: AnyCodable]? = nil, prompt: [ContentBlock], sessionId: SessionId) {
    self._meta = _meta
    self.prompt = prompt
    self.sessionId = sessionId
  }
}

/// Response from processing a user prompt.
///
/// See protocol docs: [Check for Completion](https://agentclientprotocol.com/protocol/prompt-turn#4-check-for-completion)
public struct PromptResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Indicates why the agent stopped processing the turn.
  public let stopReason: StopReason

  public init(_meta: [String: AnyCodable]? = nil, stopReason: StopReason) {
    self._meta = _meta
    self.stopReason = stopReason
  }
}

public typealias ProtocolVersion = Int

/// Request to read content from a text file.
///
/// Only available if the client supports the `fs.readTextFile` capability.
public struct ReadTextFileRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Maximum number of lines to read.
  public let limit: Int?
  /// Line number to start reading from (1-based).
  public let line: Int?
  /// Absolute path to the file to read.
  public let path: String
  /// The session ID for this request.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, limit: Int? = nil, line: Int? = nil, path: String,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.limit = limit
    self.line = line
    self.path = path
    self.sessionId = sessionId
  }
}

/// Response containing the contents of a text file.
public struct ReadTextFileResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let content: String

  public init(_meta: [String: AnyCodable]? = nil, content: String) {
    self._meta = _meta
    self.content = content
  }
}

/// Request to release a terminal and free its resources.
public struct ReleaseTerminalRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The session ID for this request.
  public let sessionId: SessionId
  /// The ID of the terminal to release.
  public let terminalId: String

  public init(_meta: [String: AnyCodable]? = nil, sessionId: SessionId, terminalId: String) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response to terminal/release method
public struct ReleaseTerminalResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

public typealias RequestId = AnyCodable

/// The prompt turn was cancelled before the user responded.
///
/// When a client sends a `session/cancel` notification to cancel an ongoing
/// prompt turn, it MUST respond to all pending `session/request_permission`
/// requests with this `Cancelled` outcome.
///
/// See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/prompt-turn#cancellation)
public struct RequestPermissionOutcomeOption1: Codable, Sendable {
  public let outcome: String

  public init(outcome: String) {
    self.outcome = outcome
  }
}

/// The user selected one of the provided options.
public struct SelectedPermissionOutcome: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the option the user selected.
  public let optionId: PermissionOptionId

  public init(_meta: [String: AnyCodable]? = nil, optionId: PermissionOptionId) {
    self._meta = _meta
    self.optionId = optionId
  }
}

public enum RequestPermissionOutcome: Codable, Sendable {
  case cancelled(RequestPermissionOutcomeOption1)
  case selected(SelectedPermissionOutcome)

  public init(from decoder: Decoder) throws {
    if let key = _DiscriminatorCodingKey(stringValue: "outcome"),
      let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
      let raw = try? container.decode(String.self, forKey: key)
    {
      switch raw {
      case "cancelled":
        if let value = try? RequestPermissionOutcomeOption1(from: decoder) {
          self = .cancelled(value)
          return
        }
      case "selected":
        if let value = try? SelectedPermissionOutcome(from: decoder) {
          self = .selected(value)
          return
        }
      default:
        break
      }
    }
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(RequestPermissionOutcomeOption1.self) {
      self = .cancelled(value)
      return
    }
    if let value = try? container.decode(SelectedPermissionOutcome.self) {
      self = .selected(value)
      return
    }
    throw DecodingError.typeMismatch(
      RequestPermissionOutcome.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No matching type for RequestPermissionOutcome"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .cancelled(let value):
      try container.encode(value)
    case .selected(let value):
      try container.encode(value)
    }
  }
}

/// Request for user permission to execute a tool call.
///
/// Sent when the agent needs authorization before performing a sensitive operation.
///
/// See protocol docs: [Requesting Permission](https://agentclientprotocol.com/protocol/tool-calls#requesting-permission)
public struct RequestPermissionRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Available permission options for the user to choose from.
  public let options: [PermissionOption]
  /// The session ID for this request.
  public let sessionId: SessionId
  /// Details about the tool call requiring permission.
  public let toolCall: ToolCallUpdate

  public init(
    _meta: [String: AnyCodable]? = nil, options: [PermissionOption], sessionId: SessionId,
    toolCall: ToolCallUpdate
  ) {
    self._meta = _meta
    self.options = options
    self.sessionId = sessionId
    self.toolCall = toolCall
  }
}

/// Response to a permission request.
public struct RequestPermissionResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The user's decision on the permission request.
  public let outcome: RequestPermissionOutcome

  public init(_meta: [String: AnyCodable]? = nil, outcome: RequestPermissionOutcome) {
    self._meta = _meta
    self.outcome = outcome
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Request parameters for resuming an existing session.
///
/// Resumes an existing session without returning previous messages (unlike `session/load`).
/// This is useful for agents that can resume sessions but don't implement full session loading.
///
/// Only available if the Agent supports the `session.resume` capability.
public struct ResumeSessionRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The working directory for this session.
  public let cwd: String
  /// List of MCP servers to connect to for this session.
  public let mcpServers: [McpServer]?
  /// The ID of the session to resume.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, cwd: String, mcpServers: [McpServer]? = nil,
    sessionId: SessionId
  ) {
    self._meta = _meta
    self.cwd = cwd
    self.mcpServers = mcpServers
    self.sessionId = sessionId
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Response from resuming an existing session.
public struct ResumeSessionResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial session configuration options if supported by the Agent.
  public let configOptions: [SessionConfigOption]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Initial model state if supported by the Agent
  public let models: SessionModelState?
  /// Initial mode state if supported by the Agent
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  public let modes: SessionModeState?

  public init(
    _meta: [String: AnyCodable]? = nil, configOptions: [SessionConfigOption]? = nil,
    models: SessionModelState? = nil, modes: SessionModeState? = nil
  ) {
    self._meta = _meta
    self.configOptions = configOptions
    self.models = models
    self.modes = modes
  }
}

/// Session capabilities supported by the agent.
///
/// As a baseline, all Agents **MUST** support `session/new`, `session/prompt`, `session/cancel`, and `session/update`.
///
/// Optionally, they **MAY** support other session methods and notifications by specifying additional capabilities.
///
/// Note: `session/load` is still handled by the top-level `load_session` capability. This will be unified in future versions of the protocol.
///
/// See protocol docs: [Session Capabilities](https://agentclientprotocol.com/protocol/initialization#session-capabilities)
public struct SessionCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Whether the agent supports `session/fork`.
  public let fork: SessionForkCapabilities?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Whether the agent supports `session/list`.
  public let list: SessionListCapabilities?
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Whether the agent supports `session/resume`.
  public let resume: SessionResumeCapabilities?

  public init(
    _meta: [String: AnyCodable]? = nil, fork: SessionForkCapabilities? = nil,
    list: SessionListCapabilities? = nil, resume: SessionResumeCapabilities? = nil
  ) {
    self._meta = _meta
    self.fork = fork
    self.list = list
    self.resume = resume
  }
}

public typealias SessionConfigGroupId = String

public typealias SessionConfigId = String

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// A single-value selector (dropdown) session configuration option payload.
public struct SessionConfigSelect: Codable, Sendable {
  /// The currently selected value.
  public let currentValue: SessionConfigValueId
  /// The set of selectable options.
  public let options: SessionConfigSelectOptions

  public init(currentValue: SessionConfigValueId, options: SessionConfigSelectOptions) {
    self.currentValue = currentValue
    self.options = options
  }
}

public enum SessionConfigOption: Codable, Sendable {
  case select(SessionConfigSelect)

  public init(from decoder: Decoder) throws {
    if let key = _DiscriminatorCodingKey(stringValue: "type"),
      let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
      let raw = try? container.decode(String.self, forKey: key)
    {
      switch raw {
      case "select":
        if let value = try? SessionConfigSelect(from: decoder) {
          self = .select(value)
          return
        }
      default:
        break
      }
    }
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(SessionConfigSelect.self) {
      self = .select(value)
      return
    }
    throw DecodingError.typeMismatch(
      SessionConfigOption.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for SessionConfigOption"
      ))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .select(let value):
      try container.encode(value)
    }
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// A group of possible values for a session configuration option.
public struct SessionConfigSelectGroup: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Unique identifier for this group.
  public let group: SessionConfigGroupId
  /// Human-readable label for this group.
  public let name: String
  /// The set of option values in this group.
  public let options: [SessionConfigSelectOption]

  public init(
    _meta: [String: AnyCodable]? = nil, group: SessionConfigGroupId, name: String,
    options: [SessionConfigSelectOption]
  ) {
    self._meta = _meta
    self.group = group
    self.name = name
    self.options = options
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// A possible value for a session configuration option.
public struct SessionConfigSelectOption: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Optional description for this option value.
  public let description: String?
  /// Human-readable label for this option value.
  public let name: String
  /// Unique identifier for this option value.
  public let value: SessionConfigValueId

  public init(
    _meta: [String: AnyCodable]? = nil, description: String? = nil, name: String,
    value: SessionConfigValueId
  ) {
    self._meta = _meta
    self.description = description
    self.name = name
    self.value = value
  }
}

public enum SessionConfigSelectOptions: Codable, Sendable {
  case sessionConfigSelectOption([SessionConfigSelectOption])
  case sessionConfigSelectGroup([SessionConfigSelectGroup])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode([SessionConfigSelectOption].self) {
      self = .sessionConfigSelectOption(value)
      return
    }
    if let value = try? container.decode([SessionConfigSelectGroup].self) {
      self = .sessionConfigSelectGroup(value)
      return
    }
    throw DecodingError.typeMismatch(
      SessionConfigSelectOptions.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No matching type for SessionConfigSelectOptions"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .sessionConfigSelectOption(let value):
      try container.encode(value)
    case .sessionConfigSelectGroup(let value):
      try container.encode(value)
    }
  }
}

public typealias SessionConfigValueId = String

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Capabilities for the `session/fork` method.
///
/// By supplying `{}` it means that the agent supports forking of sessions.
public struct SessionForkCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

public typealias SessionId = String

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Information about a session returned by session/list
public struct SessionInfo: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The working directory for this session. Must be an absolute path.
  public let cwd: String
  /// Unique identifier for the session
  public let sessionId: SessionId
  /// Human-readable title for the session
  public let title: String?
  /// ISO 8601 timestamp of last activity
  public let updatedAt: String?

  public init(
    _meta: [String: AnyCodable]? = nil, cwd: String, sessionId: SessionId, title: String? = nil,
    updatedAt: String? = nil
  ) {
    self._meta = _meta
    self.cwd = cwd
    self.sessionId = sessionId
    self.title = title
    self.updatedAt = updatedAt
  }
}

/// Update to session metadata. All fields are optional to support partial updates.
///
/// Agents send this notification to update session information like title or custom metadata.
/// This allows clients to display dynamic session names and track session state changes.
public struct SessionInfoUpdate: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Human-readable title for the session. Set to null to clear.
  public let title: String?
  /// ISO 8601 timestamp of last activity. Set to null to clear.
  public let updatedAt: String?

  public init(_meta: [String: AnyCodable]? = nil, title: String? = nil, updatedAt: String? = nil) {
    self._meta = _meta
    self.title = title
    self.updatedAt = updatedAt
  }
}

/// Capabilities for the `session/list` method.
///
/// By supplying `{}` it means that the agent supports listing of sessions.
///
/// Further capabilities can be added in the future for other means of filtering or searching the list.
public struct SessionListCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

/// A mode the agent can operate in.
///
/// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
public struct SessionMode: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let description: String?
  public let id: SessionModeId
  public let name: String

  public init(
    _meta: [String: AnyCodable]? = nil, description: String? = nil, id: SessionModeId, name: String
  ) {
    self._meta = _meta
    self.description = description
    self.id = id
    self.name = name
  }
}

public typealias SessionModeId = String

/// The set of modes and the one currently active.
public struct SessionModeState: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The set of modes that the Agent can operate in
  public let availableModes: [SessionMode]
  /// The current mode the Agent is in.
  public let currentModeId: SessionModeId

  public init(
    _meta: [String: AnyCodable]? = nil, availableModes: [SessionMode], currentModeId: SessionModeId
  ) {
    self._meta = _meta
    self.availableModes = availableModes
    self.currentModeId = currentModeId
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// The set of models and the one currently active.
public struct SessionModelState: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The set of models that the Agent can use
  public let availableModels: [ModelInfo]
  /// The current model the Agent is in.
  public let currentModelId: ModelId

  public init(
    _meta: [String: AnyCodable]? = nil, availableModels: [ModelInfo], currentModelId: ModelId
  ) {
    self._meta = _meta
    self.availableModels = availableModels
    self.currentModelId = currentModelId
  }
}

/// Notification containing a session update from the agent.
///
/// Used to stream real-time progress and results during prompt processing.
///
/// See protocol docs: [Agent Reports Output](https://agentclientprotocol.com/protocol/prompt-turn#3-agent-reports-output)
public struct SessionNotification: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the session this update pertains to.
  public let sessionId: SessionId
  /// The actual update content.
  public let update: SessionUpdate

  public init(_meta: [String: AnyCodable]? = nil, sessionId: SessionId, update: SessionUpdate) {
    self._meta = _meta
    self.sessionId = sessionId
    self.update = update
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Capabilities for the `session/resume` method.
///
/// By supplying `{}` it means that the agent supports resuming of sessions.
public struct SessionResumeCapabilities: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

/// Represents a tool call that the language model has requested.
///
/// Tool calls are actions that the agent executes on behalf of the language model,
/// such as reading files, executing code, or fetching data from external sources.
///
/// See protocol docs: [Tool Calls](https://agentclientprotocol.com/protocol/tool-calls)
public struct ToolCall: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Content produced by the tool call.
  public let content: [ToolCallContent]?
  /// The category of tool being invoked.
  /// Helps clients choose appropriate icons and UI treatment.
  public let kind: ToolKind?
  /// File locations affected by this tool call.
  /// Enables "follow-along" features in clients.
  public let locations: [ToolCallLocation]?
  /// Raw input parameters sent to the tool.
  public let rawInput: AnyCodable?
  /// Raw output returned by the tool.
  public let rawOutput: AnyCodable?
  /// Current execution status of the tool call.
  public let status: ToolCallStatus?
  /// Human-readable title describing what the tool is doing.
  public let title: String
  /// Unique identifier for this tool call within the session.
  public let toolCallId: ToolCallId

  public init(
    _meta: [String: AnyCodable]? = nil, content: [ToolCallContent]? = nil, kind: ToolKind? = nil,
    locations: [ToolCallLocation]? = nil, rawInput: AnyCodable? = nil, rawOutput: AnyCodable? = nil,
    status: ToolCallStatus? = nil, title: String, toolCallId: ToolCallId
  ) {
    self._meta = _meta
    self.content = content
    self.kind = kind
    self.locations = locations
    self.rawInput = rawInput
    self.rawOutput = rawOutput
    self.status = status
    self.title = title
    self.toolCallId = toolCallId
  }
}

/// An update to an existing tool call.
///
/// Used to report progress and results as tools execute. All fields except
/// the tool call ID are optional - only changed fields need to be included.
///
/// See protocol docs: [Updating](https://agentclientprotocol.com/protocol/tool-calls#updating)
public struct ToolCallUpdate: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Replace the content collection.
  public let content: [ToolCallContent]?
  /// Update the tool kind.
  public let kind: ToolKind?
  /// Replace the locations collection.
  public let locations: [ToolCallLocation]?
  /// Update the raw input.
  public let rawInput: AnyCodable?
  /// Update the raw output.
  public let rawOutput: AnyCodable?
  /// Update the execution status.
  public let status: ToolCallStatus?
  /// Update the human-readable title.
  public let title: String?
  /// The ID of the tool call being updated.
  public let toolCallId: ToolCallId

  public init(
    _meta: [String: AnyCodable]? = nil, content: [ToolCallContent]? = nil, kind: ToolKind? = nil,
    locations: [ToolCallLocation]? = nil, rawInput: AnyCodable? = nil, rawOutput: AnyCodable? = nil,
    status: ToolCallStatus? = nil, title: String? = nil, toolCallId: ToolCallId
  ) {
    self._meta = _meta
    self.content = content
    self.kind = kind
    self.locations = locations
    self.rawInput = rawInput
    self.rawOutput = rawOutput
    self.status = status
    self.title = title
    self.toolCallId = toolCallId
  }
}

public enum SessionUpdate: Codable, Sendable {
  case user_message_chunk(ContentChunk)
  case agent_message_chunk(ContentChunk)
  case agent_thought_chunk(ContentChunk)
  case tool_call(ToolCall)
  case tool_call_update(ToolCallUpdate)
  case plan(Plan)
  case available_commands_update(AvailableCommandsUpdate)
  case current_mode_update(CurrentModeUpdate)
  case config_option_update(ConfigOptionUpdate)
  case session_info_update(SessionInfoUpdate)

  public init(from decoder: Decoder) throws {
    if let key = _DiscriminatorCodingKey(stringValue: "sessionUpdate"),
      let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
      let raw = try? container.decode(String.self, forKey: key)
    {
      switch raw {
      case "user_message_chunk":
        if let value = try? ContentChunk(from: decoder) {
          self = .user_message_chunk(value)
          return
        }
      case "agent_message_chunk":
        if let value = try? ContentChunk(from: decoder) {
          self = .agent_message_chunk(value)
          return
        }
      case "agent_thought_chunk":
        if let value = try? ContentChunk(from: decoder) {
          self = .agent_thought_chunk(value)
          return
        }
      case "tool_call":
        if let value = try? ToolCall(from: decoder) {
          self = .tool_call(value)
          return
        }
      case "tool_call_update":
        if let value = try? ToolCallUpdate(from: decoder) {
          self = .tool_call_update(value)
          return
        }
      case "plan":
        if let value = try? Plan(from: decoder) {
          self = .plan(value)
          return
        }
      case "available_commands_update":
        if let value = try? AvailableCommandsUpdate(from: decoder) {
          self = .available_commands_update(value)
          return
        }
      case "current_mode_update":
        if let value = try? CurrentModeUpdate(from: decoder) {
          self = .current_mode_update(value)
          return
        }
      case "config_option_update":
        if let value = try? ConfigOptionUpdate(from: decoder) {
          self = .config_option_update(value)
          return
        }
      case "session_info_update":
        if let value = try? SessionInfoUpdate(from: decoder) {
          self = .session_info_update(value)
          return
        }
      default:
        break
      }
    }
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(ContentChunk.self) {
      self = .user_message_chunk(value)
      return
    }
    if let value = try? container.decode(ContentChunk.self) {
      self = .agent_message_chunk(value)
      return
    }
    if let value = try? container.decode(ContentChunk.self) {
      self = .agent_thought_chunk(value)
      return
    }
    if let value = try? container.decode(ToolCall.self) {
      self = .tool_call(value)
      return
    }
    if let value = try? container.decode(ToolCallUpdate.self) {
      self = .tool_call_update(value)
      return
    }
    if let value = try? container.decode(Plan.self) {
      self = .plan(value)
      return
    }
    if let value = try? container.decode(AvailableCommandsUpdate.self) {
      self = .available_commands_update(value)
      return
    }
    if let value = try? container.decode(CurrentModeUpdate.self) {
      self = .current_mode_update(value)
      return
    }
    if let value = try? container.decode(ConfigOptionUpdate.self) {
      self = .config_option_update(value)
      return
    }
    if let value = try? container.decode(SessionInfoUpdate.self) {
      self = .session_info_update(value)
      return
    }
    throw DecodingError.typeMismatch(
      SessionUpdate.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for SessionUpdate"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .user_message_chunk(let value):
      try container.encode(value)
    case .agent_message_chunk(let value):
      try container.encode(value)
    case .agent_thought_chunk(let value):
      try container.encode(value)
    case .tool_call(let value):
      try container.encode(value)
    case .tool_call_update(let value):
      try container.encode(value)
    case .plan(let value):
      try container.encode(value)
    case .available_commands_update(let value):
      try container.encode(value)
    case .current_mode_update(let value):
      try container.encode(value)
    case .config_option_update(let value):
      try container.encode(value)
    case .session_info_update(let value):
      try container.encode(value)
    }
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Request parameters for setting a session configuration option.
public struct SetSessionConfigOptionRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the configuration option to set.
  public let configId: SessionConfigId
  /// The ID of the session to set the configuration option for.
  public let sessionId: SessionId
  /// The ID of the configuration option value to set.
  public let value: SessionConfigValueId

  public init(
    _meta: [String: AnyCodable]? = nil, configId: SessionConfigId, sessionId: SessionId,
    value: SessionConfigValueId
  ) {
    self._meta = _meta
    self.configId = configId
    self.sessionId = sessionId
    self.value = value
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Response to `session/set_config_option` method.
public struct SetSessionConfigOptionResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The full set of configuration options and their current values.
  public let configOptions: [SessionConfigOption]

  public init(_meta: [String: AnyCodable]? = nil, configOptions: [SessionConfigOption]) {
    self._meta = _meta
    self.configOptions = configOptions
  }
}

/// Request parameters for setting a session mode.
public struct SetSessionModeRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the mode to set.
  public let modeId: SessionModeId
  /// The ID of the session to set the mode for.
  public let sessionId: SessionId

  public init(_meta: [String: AnyCodable]? = nil, modeId: SessionModeId, sessionId: SessionId) {
    self._meta = _meta
    self.modeId = modeId
    self.sessionId = sessionId
  }
}

/// Response to `session/set_mode` method.
public struct SetSessionModeResponse: Codable, Sendable {
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Request parameters for setting a session model.
public struct SetSessionModelRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The ID of the model to set.
  public let modelId: ModelId
  /// The ID of the session to set the model for.
  public let sessionId: SessionId

  public init(_meta: [String: AnyCodable]? = nil, modelId: ModelId, sessionId: SessionId) {
    self._meta = _meta
    self.modelId = modelId
    self.sessionId = sessionId
  }
}

/// **UNSTABLE**
///
/// This capability is not part of the spec yet, and may be removed or changed at any point.
///
/// Response to `session/set_model` method.
public struct SetSessionModelResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

public enum StopReason: String, Codable, Sendable {
  case end_turn = "end_turn"
  case max_tokens = "max_tokens"
  case max_turn_requests = "max_turn_requests"
  case refusal = "refusal"
  case cancelled = "cancelled"
}

/// Embed a terminal created with `terminal/create` by its id.
///
/// The terminal must be added before calling `terminal/release`.
///
/// See protocol docs: [Terminal](https://agentclientprotocol.com/protocol/terminals)
public struct Terminal: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  public let terminalId: String

  public init(_meta: [String: AnyCodable]? = nil, terminalId: String) {
    self._meta = _meta
    self.terminalId = terminalId
  }
}

/// Exit status of a terminal command.
public struct TerminalExitStatus: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The process exit code (may be null if terminated by signal).
  public let exitCode: Int?
  /// The signal that terminated the process (may be null if exited normally).
  public let signal: String?

  public init(_meta: [String: AnyCodable]? = nil, exitCode: Int? = nil, signal: String? = nil) {
    self._meta = _meta
    self.exitCode = exitCode
    self.signal = signal
  }
}

/// Request to get the current output and status of a terminal.
public struct TerminalOutputRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The session ID for this request.
  public let sessionId: SessionId
  /// The ID of the terminal to get output from.
  public let terminalId: String

  public init(_meta: [String: AnyCodable]? = nil, sessionId: SessionId, terminalId: String) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response containing the terminal output and exit status.
public struct TerminalOutputResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Exit status if the command has completed.
  public let exitStatus: TerminalExitStatus?
  /// The terminal output captured so far.
  public let output: String
  /// Whether the output was truncated due to byte limits.
  public let truncated: Bool

  public init(
    _meta: [String: AnyCodable]? = nil, exitStatus: TerminalExitStatus? = nil, output: String,
    truncated: Bool
  ) {
    self._meta = _meta
    self.exitStatus = exitStatus
    self.output = output
    self.truncated = truncated
  }
}

public enum ToolCallContent: Codable, Sendable {
  case content(Content)
  case diff(Diff)
  case terminal(Terminal)

  public init(from decoder: Decoder) throws {
    if let key = _DiscriminatorCodingKey(stringValue: "type"),
      let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
      let raw = try? container.decode(String.self, forKey: key)
    {
      switch raw {
      case "content":
        if let value = try? Content(from: decoder) {
          self = .content(value)
          return
        }
      case "diff":
        if let value = try? Diff(from: decoder) {
          self = .diff(value)
          return
        }
      case "terminal":
        if let value = try? Terminal(from: decoder) {
          self = .terminal(value)
          return
        }
      default:
        break
      }
    }
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(Content.self) {
      self = .content(value)
      return
    }
    if let value = try? container.decode(Diff.self) {
      self = .diff(value)
      return
    }
    if let value = try? container.decode(Terminal.self) {
      self = .terminal(value)
      return
    }
    throw DecodingError.typeMismatch(
      ToolCallContent.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for ToolCallContent"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .content(let value):
      try container.encode(value)
    case .diff(let value):
      try container.encode(value)
    case .terminal(let value):
      try container.encode(value)
    }
  }
}

public typealias ToolCallId = String

/// A file location being accessed or modified by a tool.
///
/// Enables clients to implement "follow-along" features that track
/// which files the agent is working with in real-time.
///
/// See protocol docs: [Following the Agent](https://agentclientprotocol.com/protocol/tool-calls#following-the-agent)
public struct ToolCallLocation: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// Optional line number within the file.
  public let line: Int?
  /// The file path being accessed or modified.
  public let path: String

  public init(_meta: [String: AnyCodable]? = nil, line: Int? = nil, path: String) {
    self._meta = _meta
    self.line = line
    self.path = path
  }
}

public enum ToolCallStatus: String, Codable, Sendable {
  case pending = "pending"
  case in_progress = "in_progress"
  case completed = "completed"
  case failed = "failed"
}

public enum ToolKind: String, Codable, Sendable {
  case read = "read"
  case edit = "edit"
  case delete = "delete"
  case move = "move"
  case search = "search"
  case execute = "execute"
  case think = "think"
  case fetch = "fetch"
  case switch_mode = "switch_mode"
  case other = "other"
}

/// Request to wait for a terminal command to exit.
public struct WaitForTerminalExitRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The session ID for this request.
  public let sessionId: SessionId
  /// The ID of the terminal to wait for.
  public let terminalId: String

  public init(_meta: [String: AnyCodable]? = nil, sessionId: SessionId, terminalId: String) {
    self._meta = _meta
    self.sessionId = sessionId
    self.terminalId = terminalId
  }
}

/// Response containing the exit status of a terminal command.
public struct WaitForTerminalExitResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The process exit code (may be null if terminated by signal).
  public let exitCode: Int?
  /// The signal that terminated the process (may be null if exited normally).
  public let signal: String?

  public init(_meta: [String: AnyCodable]? = nil, exitCode: Int? = nil, signal: String? = nil) {
    self._meta = _meta
    self.exitCode = exitCode
    self.signal = signal
  }
}

/// Request to write content to a text file.
///
/// Only available if the client supports the `fs.writeTextFile` capability.
public struct WriteTextFileRequest: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
  /// The text content to write to the file.
  public let content: String
  /// Absolute path to the file to write.
  public let path: String
  /// The session ID for this request.
  public let sessionId: SessionId

  public init(
    _meta: [String: AnyCodable]? = nil, content: String, path: String, sessionId: SessionId
  ) {
    self._meta = _meta
    self.content = content
    self.path = path
    self.sessionId = sessionId
  }
}

/// Response to `fs/write_text_file`
public struct WriteTextFileResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?

  public init(_meta: [String: AnyCodable]? = nil) {
    self._meta = _meta
  }
}

public enum AgentNotificationParams: Codable, Sendable {
  case sessionNotification(SessionNotification)
  case extNotification(ExtNotification)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(SessionNotification.self) {
      self = .sessionNotification(value)
      return
    }
    if let value = try? container.decode(ExtNotification.self) {
      self = .extNotification(value)
      return
    }
    throw DecodingError.typeMismatch(
      AgentNotificationParams.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No matching type for AgentNotificationParams"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .sessionNotification(let value):
      try container.encode(value)
    case .extNotification(let value):
      try container.encode(value)
    }
  }
}

public enum AgentRequestParams: Codable, Sendable {
  case writeTextFileRequest(WriteTextFileRequest)
  case readTextFileRequest(ReadTextFileRequest)
  case requestPermissionRequest(RequestPermissionRequest)
  case createTerminalRequest(CreateTerminalRequest)
  case terminalOutputRequest(TerminalOutputRequest)
  case releaseTerminalRequest(ReleaseTerminalRequest)
  case waitForTerminalExitRequest(WaitForTerminalExitRequest)
  case killTerminalCommandRequest(KillTerminalCommandRequest)
  case extRequest(ExtRequest)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(WriteTextFileRequest.self) {
      self = .writeTextFileRequest(value)
      return
    }
    if let value = try? container.decode(ReadTextFileRequest.self) {
      self = .readTextFileRequest(value)
      return
    }
    if let value = try? container.decode(RequestPermissionRequest.self) {
      self = .requestPermissionRequest(value)
      return
    }
    if let value = try? container.decode(CreateTerminalRequest.self) {
      self = .createTerminalRequest(value)
      return
    }
    if let value = try? container.decode(TerminalOutputRequest.self) {
      self = .terminalOutputRequest(value)
      return
    }
    if let value = try? container.decode(ReleaseTerminalRequest.self) {
      self = .releaseTerminalRequest(value)
      return
    }
    if let value = try? container.decode(WaitForTerminalExitRequest.self) {
      self = .waitForTerminalExitRequest(value)
      return
    }
    if let value = try? container.decode(KillTerminalCommandRequest.self) {
      self = .killTerminalCommandRequest(value)
      return
    }
    if let value = try? container.decode(ExtRequest.self) {
      self = .extRequest(value)
      return
    }
    throw DecodingError.typeMismatch(
      AgentRequestParams.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for AgentRequestParams")
    )
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .writeTextFileRequest(let value):
      try container.encode(value)
    case .readTextFileRequest(let value):
      try container.encode(value)
    case .requestPermissionRequest(let value):
      try container.encode(value)
    case .createTerminalRequest(let value):
      try container.encode(value)
    case .terminalOutputRequest(let value):
      try container.encode(value)
    case .releaseTerminalRequest(let value):
      try container.encode(value)
    case .waitForTerminalExitRequest(let value):
      try container.encode(value)
    case .killTerminalCommandRequest(let value):
      try container.encode(value)
    case .extRequest(let value):
      try container.encode(value)
    }
  }
}

public enum ResultOption: Codable, Sendable {
  case initializeResponse(InitializeResponse)
  case authenticateResponse(AuthenticateResponse)
  case newSessionResponse(NewSessionResponse)
  case loadSessionResponse(LoadSessionResponse)
  case listSessionsResponse(ListSessionsResponse)
  case forkSessionResponse(ForkSessionResponse)
  case resumeSessionResponse(ResumeSessionResponse)
  case setSessionModeResponse(SetSessionModeResponse)
  case setSessionConfigOptionResponse(SetSessionConfigOptionResponse)
  case promptResponse(PromptResponse)
  case setSessionModelResponse(SetSessionModelResponse)
  case extResponse(ExtResponse)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(InitializeResponse.self) {
      self = .initializeResponse(value)
      return
    }
    if let value = try? container.decode(AuthenticateResponse.self) {
      self = .authenticateResponse(value)
      return
    }
    if let value = try? container.decode(NewSessionResponse.self) {
      self = .newSessionResponse(value)
      return
    }
    if let value = try? container.decode(LoadSessionResponse.self) {
      self = .loadSessionResponse(value)
      return
    }
    if let value = try? container.decode(ListSessionsResponse.self) {
      self = .listSessionsResponse(value)
      return
    }
    if let value = try? container.decode(ForkSessionResponse.self) {
      self = .forkSessionResponse(value)
      return
    }
    if let value = try? container.decode(ResumeSessionResponse.self) {
      self = .resumeSessionResponse(value)
      return
    }
    if let value = try? container.decode(SetSessionModeResponse.self) {
      self = .setSessionModeResponse(value)
      return
    }
    if let value = try? container.decode(SetSessionConfigOptionResponse.self) {
      self = .setSessionConfigOptionResponse(value)
      return
    }
    if let value = try? container.decode(PromptResponse.self) {
      self = .promptResponse(value)
      return
    }
    if let value = try? container.decode(SetSessionModelResponse.self) {
      self = .setSessionModelResponse(value)
      return
    }
    if let value = try? container.decode(ExtResponse.self) {
      self = .extResponse(value)
      return
    }
    throw DecodingError.typeMismatch(
      ResultOption.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for ResultOption"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .initializeResponse(let value):
      try container.encode(value)
    case .authenticateResponse(let value):
      try container.encode(value)
    case .newSessionResponse(let value):
      try container.encode(value)
    case .loadSessionResponse(let value):
      try container.encode(value)
    case .listSessionsResponse(let value):
      try container.encode(value)
    case .forkSessionResponse(let value):
      try container.encode(value)
    case .resumeSessionResponse(let value):
      try container.encode(value)
    case .setSessionModeResponse(let value):
      try container.encode(value)
    case .setSessionConfigOptionResponse(let value):
      try container.encode(value)
    case .promptResponse(let value):
      try container.encode(value)
    case .setSessionModelResponse(let value):
      try container.encode(value)
    case .extResponse(let value):
      try container.encode(value)
    }
  }
}

public enum ClientNotificationParams: Codable, Sendable {
  case cancelNotification(CancelNotification)
  case extNotification(ExtNotification)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(CancelNotification.self) {
      self = .cancelNotification(value)
      return
    }
    if let value = try? container.decode(ExtNotification.self) {
      self = .extNotification(value)
      return
    }
    throw DecodingError.typeMismatch(
      ClientNotificationParams.self,
      DecodingError.Context(
        codingPath: decoder.codingPath,
        debugDescription: "No matching type for ClientNotificationParams"))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .cancelNotification(let value):
      try container.encode(value)
    case .extNotification(let value):
      try container.encode(value)
    }
  }
}

public enum ClientRequestParams: Codable, Sendable {
  case initializeRequest(InitializeRequest)
  case authenticateRequest(AuthenticateRequest)
  case newSessionRequest(NewSessionRequest)
  case loadSessionRequest(LoadSessionRequest)
  case listSessionsRequest(ListSessionsRequest)
  case forkSessionRequest(ForkSessionRequest)
  case resumeSessionRequest(ResumeSessionRequest)
  case setSessionModeRequest(SetSessionModeRequest)
  case setSessionConfigOptionRequest(SetSessionConfigOptionRequest)
  case promptRequest(PromptRequest)
  case setSessionModelRequest(SetSessionModelRequest)
  case extRequest(ExtRequest)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(InitializeRequest.self) {
      self = .initializeRequest(value)
      return
    }
    if let value = try? container.decode(AuthenticateRequest.self) {
      self = .authenticateRequest(value)
      return
    }
    if let value = try? container.decode(NewSessionRequest.self) {
      self = .newSessionRequest(value)
      return
    }
    if let value = try? container.decode(LoadSessionRequest.self) {
      self = .loadSessionRequest(value)
      return
    }
    if let value = try? container.decode(ListSessionsRequest.self) {
      self = .listSessionsRequest(value)
      return
    }
    if let value = try? container.decode(ForkSessionRequest.self) {
      self = .forkSessionRequest(value)
      return
    }
    if let value = try? container.decode(ResumeSessionRequest.self) {
      self = .resumeSessionRequest(value)
      return
    }
    if let value = try? container.decode(SetSessionModeRequest.self) {
      self = .setSessionModeRequest(value)
      return
    }
    if let value = try? container.decode(SetSessionConfigOptionRequest.self) {
      self = .setSessionConfigOptionRequest(value)
      return
    }
    if let value = try? container.decode(PromptRequest.self) {
      self = .promptRequest(value)
      return
    }
    if let value = try? container.decode(SetSessionModelRequest.self) {
      self = .setSessionModelRequest(value)
      return
    }
    if let value = try? container.decode(ExtRequest.self) {
      self = .extRequest(value)
      return
    }
    throw DecodingError.typeMismatch(
      ClientRequestParams.self,
      DecodingError.Context(
        codingPath: decoder.codingPath, debugDescription: "No matching type for ClientRequestParams"
      ))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .initializeRequest(let value):
      try container.encode(value)
    case .authenticateRequest(let value):
      try container.encode(value)
    case .newSessionRequest(let value):
      try container.encode(value)
    case .loadSessionRequest(let value):
      try container.encode(value)
    case .listSessionsRequest(let value):
      try container.encode(value)
    case .forkSessionRequest(let value):
      try container.encode(value)
    case .resumeSessionRequest(let value):
      try container.encode(value)
    case .setSessionModeRequest(let value):
      try container.encode(value)
    case .setSessionConfigOptionRequest(let value):
      try container.encode(value)
    case .promptRequest(let value):
      try container.encode(value)
    case .setSessionModelRequest(let value):
      try container.encode(value)
    case .extRequest(let value):
      try container.encode(value)
    }
  }
}

private struct _DiscriminatorCodingKey: CodingKey {
  var stringValue: String
  var intValue: Int?
  init?(stringValue: String) { self.stringValue = stringValue }
  init?(intValue: Int) { return nil }
}
public enum Role: String, Codable, Sendable {
  case assistant = "assistant"
  case user = "user"
}

public struct AnyCodable: Codable, @unchecked Sendable {
  public let value: Any

  public init(_ value: Any) {
    self.value = value
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let intValue = try? container.decode(Int.self) {
      value = intValue
    } else if let doubleValue = try? container.decode(Double.self) {
      value = doubleValue
    } else if let stringValue = try? container.decode(String.self) {
      value = stringValue
    } else if let boolValue = try? container.decode(Bool.self) {
      value = boolValue
    } else if let dictValue = try? container.decode([String: AnyCodable].self) {
      value = dictValue
    } else if let arrayValue = try? container.decode([AnyCodable].self) {
      value = arrayValue
    } else {
      value = NSNull()
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    if let intValue = value as? Int {
      try container.encode(intValue)
    } else if let doubleValue = value as? Double {
      try container.encode(doubleValue)
    } else if let stringValue = value as? String {
      try container.encode(stringValue)
    } else if let boolValue = value as? Bool {
      try container.encode(boolValue)
    } else if let dictValue = value as? [String: AnyCodable] {
      try container.encode(dictValue)
    } else if let arrayValue = value as? [AnyCodable] {
      try container.encode(arrayValue)
    }
  }
}
