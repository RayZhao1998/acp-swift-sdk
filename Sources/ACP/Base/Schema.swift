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
}

public struct AgentNotification: Codable {
  public let method: String
  public let params: AgentNotificationParams?
}

public struct AgentRequest: Codable {
  public let id: RequestId
  public let method: String
  public let params: AgentRequestParams?
}

struct AgentResponseOption1: Codable {
  let id: RequestId
  /// All possible responses that an agent can send to a client.
  ///
  /// This enum is used internally for routing RPC responses. You typically won't need
  /// to use this directly - the responses are handled automatically by the connection.
  ///
  /// These are responses to the corresponding `ClientRequest` variants.
  let result: ResultOption
}

struct AgentResponseOption2: Codable {
  let error: JSONRPCError
  let id: RequestId
}

enum AgentResponse: Codable {
  case agentResponseOption1(AgentResponseOption1)
  case agentResponseOption2(AgentResponseOption2)

  init(from decoder: Decoder) throws {
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

  func encode(to encoder: Encoder) throws {
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
  let _meta: [String: AnyCodable]?
  /// The ID of the authentication method to use.
  /// Must be one of the methods advertised in the initialize response.
  let methodId: String
}

/// Response to the `authenticate` method.
public struct AuthenticateResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  let _meta: [String: AnyCodable]?
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
  let _meta: [String: AnyCodable]?
  /// The ID of the session to cancel operations for.
  let sessionId: SessionId
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
  let _meta: [String: AnyCodable]?
  /// File system capabilities supported by the client.
  /// Determines which file operations the agent can request.
  let fs: FileSystemCapability?
  /// Whether the Client support all `terminal/*` methods.
  let terminal: Bool?

  public init(
    _meta: [String: AnyCodable]? = nil,
    fs: FileSystemCapability? = nil,
    terminal: Bool? = nil
  ) {
    self._meta = _meta
    self.fs = fs
    self.terminal = terminal
  }
}

struct ClientNotification: Codable {
  let method: String
  let params: ClientNotificationParams?
}

struct ClientRequest: Codable {
  let id: RequestId
  let method: String
  let params: ClientRequestParams?
}

struct ClientResponseOption1: Codable {
  let id: RequestId
  /// All possible responses that a client can send to an agent.
  ///
  /// This enum is used internally for routing RPC responses. You typically won't need
  /// to use this directly - the responses are handled automatically by the connection.
  ///
  /// These are responses to the corresponding `AgentRequest` variants.
  let result: ResultOption
}

struct ClientResponseOption2: Codable {
  let error: JSONRPCError
  let id: RequestId
}

enum ClientResponse: Codable {
  case clientResponseOption1(ClientResponseOption1)
  case clientResponseOption2(ClientResponseOption2)

  init(from decoder: Decoder) throws {
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

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .clientResponseOption1(let value):
      try container.encode(value)
    case .clientResponseOption2(let value):
      try container.encode(value)
    }
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

  public init(
    text: String,
    annotations: Annotations? = nil,
    _meta: [String: AnyCodable]? = nil
  ) {
    self.text = text
    self.annotations = annotations
    self._meta = _meta
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
}

/// A resource that the server is capable of reading, included in a prompt or tool call result.
public struct ResourceLink: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  let _meta: [String: AnyCodable]?
  let annotations: Annotations?
  let description: String?
  let mimeType: String?
  let name: String
  let size: Int?
  let title: String?
  let uri: String
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
    guard let typeKey = _DiscriminatorCodingKey(stringValue: "type") else {
      throw EncodingError.invalidValue(
        self,
        EncodingError.Context(
          codingPath: encoder.codingPath, debugDescription: "Unable to encode discriminator key"))
    }
    var container = encoder.container(keyedBy: _DiscriminatorCodingKey.self)
    switch self {
    case .text(let value):
      try container.encode("text", forKey: typeKey)
      try value.encode(to: encoder)
    case .image(let value):
      try container.encode("image", forKey: typeKey)
      try value.encode(to: encoder)
    case .audio(let value):
      try container.encode("audio", forKey: typeKey)
      try value.encode(to: encoder)
    case .resource_link(let value):
      try container.encode("resource_link", forKey: typeKey)
      try value.encode(to: encoder)
    case .resource(let value):
      try container.encode("resource", forKey: typeKey)
      try value.encode(to: encoder)
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
}

/// Response containing the ID of the created terminal.
public struct CreateTerminalResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  let _meta: [String: AnyCodable]?
  /// The unique identifier for the created terminal.
  let terminalId: String
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
  let _meta: [String: AnyCodable]?
  /// Whether the Client supports `fs/read_text_file` requests.
  let readTextFile: Bool?
  /// Whether the Client supports `fs/write_text_file` requests.
  let writeTextFile: Bool?

  public init(
    _meta: [String: AnyCodable]? = nil,
    readTextFile: Bool? = nil,
    writeTextFile: Bool? = nil
  ) {
    self._meta = _meta
    self.readTextFile = readTextFile
    self.writeTextFile = writeTextFile
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
    name: String, version: String, title: String? = nil, _meta: [String: AnyCodable]? = nil
  ) {
    self.name = name
    self.version = version
    self.title = title
    self._meta = _meta
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
  let _meta: [String: AnyCodable]?
  /// Capabilities supported by the client.
  let clientCapabilities: ClientCapabilities?
  /// Information about the Client name and version sent to the Agent.
  ///
  /// Note: in future versions of the protocol, this will be required.
  let clientInfo: Implementation?
  /// The latest protocol version supported by the client.
  let protocolVersion: ProtocolVersion

  public init(
    protocolVersion: ProtocolVersion, clientCapabilities: ClientCapabilities? = nil,
    clientInfo: Implementation? = nil, _meta: [String: AnyCodable]? = nil
  ) {
    self.protocolVersion = protocolVersion
    self.clientCapabilities = clientCapabilities
    self.clientInfo = clientInfo
    self._meta = _meta
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
}

/// Response to terminal/kill command method
public struct KillTerminalCommandResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
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
    sessionId: SessionId,
    cwd: String,
    mcpServers: [McpServer],
    _meta: [String: AnyCodable]? = nil
  ) {
    self.sessionId = sessionId
    self.cwd = cwd
    self.mcpServers = mcpServers
    self._meta = _meta
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
  /// Initial mode state if supported by the Agent
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  public let modes: SessionModeState?
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

  public init(cwd: String, mcpServers: [McpServer], _meta: [String: AnyCodable]? = nil) {
    self.cwd = cwd
    self.mcpServers = mcpServers
    self._meta = _meta
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
  /// Initial mode state if supported by the Agent
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  public let modes: SessionModeState?
  /// Unique identifier for the created session.
  ///
  /// Used in all subsequent requests for this conversation.
  public let sessionId: SessionId
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
  let _meta: [String: AnyCodable]?
  /// Human-readable description of what this task aims to accomplish.
  let content: String
  /// The relative importance of this task.
  /// Used to indicate which tasks are most critical to the overall goal.
  let priority: PlanEntryPriority
  /// Current execution status of this task.
  let status: PlanEntryStatus
}

enum PlanEntryPriority: String, Codable {
  case high = "high"
  case medium = "medium"
  case low = "low"
}

enum PlanEntryStatus: String, Codable {
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

  public init(
    sessionId: SessionId,
    prompt: [ContentBlock],
    _meta: [String: AnyCodable]? = nil
  ) {
    self.sessionId = sessionId
    self.prompt = prompt
    self._meta = _meta
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
}

/// Response to terminal/release method
public struct ReleaseTerminalResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
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

  public init(optionId: PermissionOptionId, _meta: [String: AnyCodable]? = nil) {
    self.optionId = optionId
    self._meta = _meta
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

  public init(outcome: RequestPermissionOutcome, _meta: [String: AnyCodable]? = nil) {
    self.outcome = outcome
    self._meta = _meta
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
}

public typealias SessionId = String

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
    }
  }
}

/// Request parameters for setting a session mode.
struct SetSessionModeRequest: Codable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  let _meta: [String: AnyCodable]?
  /// The ID of the mode to set.
  let modeId: SessionModeId
  /// The ID of the session to set the mode for.
  let sessionId: SessionId
}

/// Response to `session/set_mode` method.
struct SetSessionModeResponse: Codable {
  let _meta: [String: AnyCodable]?
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
  let sessionId: SessionId
}

/// Response to `fs/write_text_file`
public struct WriteTextFileResponse: Codable, Sendable {
  /// The _meta property is reserved by ACP to allow clients and agents to attach additional
  /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
  /// these keys.
  ///
  /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
  public let _meta: [String: AnyCodable]?
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

enum ResultOption: Codable {
  case initializeResponse(InitializeResponse)
  case authenticateResponse(AuthenticateResponse)
  case newSessionResponse(NewSessionResponse)
  case loadSessionResponse(LoadSessionResponse)
  case setSessionModeResponse(SetSessionModeResponse)
  case promptResponse(PromptResponse)
  case extResponse(ExtResponse)

  init(from decoder: Decoder) throws {
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
    if let value = try? container.decode(SetSessionModeResponse.self) {
      self = .setSessionModeResponse(value)
      return
    }
    if let value = try? container.decode(PromptResponse.self) {
      self = .promptResponse(value)
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

  func encode(to encoder: Encoder) throws {
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
    case .setSessionModeResponse(let value):
      try container.encode(value)
    case .promptResponse(let value):
      try container.encode(value)
    case .extResponse(let value):
      try container.encode(value)
    }
  }
}

enum ClientNotificationParams: Codable {
  case cancelNotification(CancelNotification)
  case extNotification(ExtNotification)

  init(from decoder: Decoder) throws {
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

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .cancelNotification(let value):
      try container.encode(value)
    case .extNotification(let value):
      try container.encode(value)
    }
  }
}

enum ClientRequestParams: Codable {
  case initializeRequest(InitializeRequest)
  case authenticateRequest(AuthenticateRequest)
  case newSessionRequest(NewSessionRequest)
  case loadSessionRequest(LoadSessionRequest)
  case setSessionModeRequest(SetSessionModeRequest)
  case promptRequest(PromptRequest)
  case extRequest(ExtRequest)

  init(from decoder: Decoder) throws {
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
    if let value = try? container.decode(SetSessionModeRequest.self) {
      self = .setSessionModeRequest(value)
      return
    }
    if let value = try? container.decode(PromptRequest.self) {
      self = .promptRequest(value)
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

  func encode(to encoder: Encoder) throws {
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
    case .setSessionModeRequest(let value):
      try container.encode(value)
    case .promptRequest(let value):
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

public struct AnyCodable: Codable, Sendable {
  enum Value: Sendable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case dictionary([String: AnyCodable])
    case array([AnyCodable])
    case null
  }

  let value: Value

  init(_ value: Any) {
    if let intValue = value as? Int {
      self.value = .int(intValue)
    } else if let doubleValue = value as? Double {
      self.value = .double(doubleValue)
    } else if let stringValue = value as? String {
      self.value = .string(stringValue)
    } else if let boolValue = value as? Bool {
      self.value = .bool(boolValue)
    } else if let dictValue = value as? [String: AnyCodable] {
      self.value = .dictionary(dictValue)
    } else if let arrayValue = value as? [AnyCodable] {
      self.value = .array(arrayValue)
    } else if let encodableValue = value as? Encodable,
      let encoded = AnyCodable.wrap(encodableValue)
    {
      self = encoded
    } else {
      self.value = .null
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let intValue = try? container.decode(Int.self) {
      value = .int(intValue)
    } else if let doubleValue = try? container.decode(Double.self) {
      value = .double(doubleValue)
    } else if let stringValue = try? container.decode(String.self) {
      value = .string(stringValue)
    } else if let boolValue = try? container.decode(Bool.self) {
      value = .bool(boolValue)
    } else if let dictValue = try? container.decode([String: AnyCodable].self) {
      value = .dictionary(dictValue)
    } else if let arrayValue = try? container.decode([AnyCodable].self) {
      value = .array(arrayValue)
    } else if container.decodeNil() {
      value = .null
    } else {
      value = .null
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch value {
    case .int(let intValue):
      try container.encode(intValue)
    case .double(let doubleValue):
      try container.encode(doubleValue)
    case .string(let stringValue):
      try container.encode(stringValue)
    case .bool(let boolValue):
      try container.encode(boolValue)
    case .dictionary(let dictValue):
      try container.encode(dictValue)
    case .array(let arrayValue):
      try container.encode(arrayValue)
    case .null:
      try container.encodeNil()
    }
  }

  private static func wrap(_ encodable: Encodable) -> AnyCodable? {
    // Encode arbitrary Encodable to JSON and rehydrate into a concrete AnyCodable tree.
    guard let data = try? JSONEncoder().encode(AnyEncodableBox(encodable)),
      let jsonObject = try? JSONSerialization.jsonObject(with: data)
    else { return nil }

    return fromJSONObject(jsonObject)
  }

  private static func fromJSONObject(_ object: Any) -> AnyCodable {
    switch object {
    case let intValue as Int:
      return AnyCodable(intValue)
    case let doubleValue as Double:
      return AnyCodable(doubleValue)
    case let stringValue as String:
      return AnyCodable(stringValue)
    case let boolValue as Bool:
      return AnyCodable(boolValue)
    case let dictValue as [String: Any]:
      let mapped = dictValue.mapValues { fromJSONObject($0) }
      return AnyCodable(mapped)
    case let arrayValue as [Any]:
      let mapped = arrayValue.map { fromJSONObject($0) }
      return AnyCodable(mapped)
    default:
      return AnyCodable(() as Any)
    }
  }

  private struct AnyEncodableBox: Encodable {
    let wrapped: Encodable
    init(_ wrapped: Encodable) { self.wrapped = wrapped }
    func encode(to encoder: Encoder) throws {
      try wrapped.encode(to: encoder)
    }
  }
}
