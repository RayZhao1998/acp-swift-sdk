import Foundation

/// Capabilities supported by the agent.
///
/// Advertised during initialization to inform the client about
/// available features and content types.
///
/// See protocol docs: [Agent Capabilities](https://agentclientprotocol.com/protocol/initialization#agent-capabilities)
struct AgentCapabilities: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Whether the agent supports `session/load`.
    let loadSession: Bool?
    /// MCP capabilities supported by the agent.
    let mcpCapabilities: McpCapabilities?
    /// Prompt capabilities supported by the agent.
    let promptCapabilities: PromptCapabilities?
    let sessionCapabilities: SessionCapabilities?
}

struct AgentNotification: Codable {
    let method: String
    let params: AgentNotificationParams?
}

struct AgentRequest: Codable {
    let id: RequestId
    let method: String
    let params: AgentRequestParams?
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
    let error: Error
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
        throw DecodingError.typeMismatch(AgentResponse.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for AgentResponse"))
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
struct Annotations: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let audience: [Role]?
    let lastModified: String?
    let priority: Double?
}

/// Audio provided to or from an LLM.
struct AudioContent: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let annotations: Annotations?
    let data: String
    let mimeType: String
}

/// Describes an available authentication method.
struct AuthMethod: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Optional description providing more details about this authentication method.
    let description: String?
    /// Unique identifier for this authentication method.
    let id: String
    /// Human-readable name of the authentication method.
    let name: String
}

/// Request parameters for the authenticate method.
///
/// Specifies which authentication method to use.
struct AuthenticateRequest: Codable {
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
struct AuthenticateResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
}

/// Information about a command.
struct AvailableCommand: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Human-readable description of what the command does.
    let description: String
    /// Input for the command if required
    let input: AvailableCommandInput?
    /// Command name (e.g., `create_plan`, `research_codebase`).
    let name: String
}

/// All text that was typed after the command name is provided as input.
struct UnstructuredCommandInput: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// A hint to display when the input hasn't been provided yet
    let hint: String
}

enum AvailableCommandInput: Codable {
    case unstructuredCommandInput(UnstructuredCommandInput)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(UnstructuredCommandInput.self) {
            self = .unstructuredCommandInput(value)
            return
        }
        throw DecodingError.typeMismatch(AvailableCommandInput.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for AvailableCommandInput"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .unstructuredCommandInput(let value):
            try container.encode(value)
        }
    }
}

/// Available commands are ready or have changed
struct AvailableCommandsUpdate: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Commands the agent can execute
    let availableCommands: [AvailableCommand]
}

/// Binary resource contents.
struct BlobResourceContents: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let blob: String
    let mimeType: String?
    let uri: String
}

/// Notification to cancel ongoing operations for a session.
///
/// See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/prompt-turn#cancellation)
struct CancelNotification: Codable {
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
struct ClientCapabilities: Codable {
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
    let error: Error
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
        throw DecodingError.typeMismatch(ClientResponse.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for ClientResponse"))
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
struct Content: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The actual content block.
    let content: ContentBlock
}

/// Text provided to or from an LLM.
struct TextContent: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let annotations: Annotations?
    let text: String
}

/// An image provided to or from an LLM.
struct ImageContent: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let annotations: Annotations?
    let data: String
    let mimeType: String
    let uri: String?
}

/// A resource that the server is capable of reading, included in a prompt or tool call result.
struct ResourceLink: Codable {
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
struct EmbeddedResource: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let annotations: Annotations?
    let resource: EmbeddedResourceResource
}

enum ContentBlock: Codable {
    case text(TextContent)
    case image(ImageContent)
    case audio(AudioContent)
    case resource_link(ResourceLink)
    case resource(EmbeddedResource)

    init(from decoder: Decoder) throws {
        if let key = _DiscriminatorCodingKey(stringValue: "type"),
           let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
           let raw = try? container.decode(String.self, forKey: key) {
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
        throw DecodingError.typeMismatch(ContentBlock.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for ContentBlock"))
    }

    func encode(to encoder: Encoder) throws {
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
struct ContentChunk: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// A single item of content
    let content: ContentBlock
}

/// Request to create a new terminal and execute a command.
struct CreateTerminalRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Array of command arguments.
    let args: [String]?
    /// The command to execute.
    let command: String
    /// Working directory for the command (absolute path).
    let cwd: String?
    /// Environment variables for the command.
    let env: [EnvVariable]?
    /// Maximum number of output bytes to retain.
    ///
    /// When the limit is exceeded, the Client truncates from the beginning of the output
    /// to stay within the limit.
    ///
    /// The Client MUST ensure truncation happens at a character boundary to maintain valid
    /// string output, even if this means the retained output is slightly less than the
    /// specified limit.
    let outputByteLimit: Int?
    /// The session ID for this request.
    let sessionId: SessionId
}

/// Response containing the ID of the created terminal.
struct CreateTerminalResponse: Codable {
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
struct CurrentModeUpdate: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The ID of the current mode
    let currentModeId: SessionModeId
}

/// A diff representing file modifications.
///
/// Shows changes to files in a format suitable for display in the client UI.
///
/// See protocol docs: [Content](https://agentclientprotocol.com/protocol/tool-calls#content)
struct Diff: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The new content after modification.
    let newText: String
    /// The original content (None for new files).
    let oldText: String?
    /// The file path being modified.
    let path: String
}

/// Text-based resource contents.
struct TextResourceContents: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let mimeType: String?
    let text: String
    let uri: String
}

enum EmbeddedResourceResource: Codable {
    case textResourceContents(TextResourceContents)
    case blobResourceContents(BlobResourceContents)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(TextResourceContents.self) {
            self = .textResourceContents(value)
            return
        }
        if let value = try? container.decode(BlobResourceContents.self) {
            self = .blobResourceContents(value)
            return
        }
        throw DecodingError.typeMismatch(EmbeddedResourceResource.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for EmbeddedResourceResource"))
    }

    func encode(to encoder: Encoder) throws {
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
struct EnvVariable: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The name of the environment variable.
    let name: String
    /// The value to set for the environment variable.
    let value: String
}

/// JSON-RPC error object.
///
/// Represents an error that occurred during method execution, following the
/// JSON-RPC 2.0 error object specification with optional additional data.
///
/// See protocol docs: [JSON-RPC Error Object](https://www.jsonrpc.org/specification#error_object)
struct Error: Codable {
    /// A number indicating the error type that occurred.
    /// This must be an integer as defined in the JSON-RPC specification.
    let code: ErrorCode
    /// Optional primitive or structured value that contains additional information about the error.
    /// This may include debugging information or context-specific details.
    let data: AnyCodable?
    /// A string providing a short description of the error.
    /// The message should be limited to a concise single sentence.
    let message: String
}

typealias ErrorCode = AnyCodable

/// Allows the Agent to send an arbitrary notification that is not part of the ACP spec.
/// Extension notifications provide a way to send one-way messages for custom functionality
/// while maintaining protocol compatibility.
///
/// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
struct ExtNotification: Codable {
}

/// Allows for sending an arbitrary request that is not part of the ACP spec.
/// Extension methods provide a way to add custom functionality while maintaining
/// protocol compatibility.
///
/// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
struct ExtRequest: Codable {
}

/// Allows for sending an arbitrary response to an [`ExtRequest`] that is not part of the ACP spec.
/// Extension methods provide a way to add custom functionality while maintaining
/// protocol compatibility.
///
/// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
struct ExtResponse: Codable {
}

/// Filesystem capabilities supported by the client.
/// File system capabilities that a client may support.
///
/// See protocol docs: [FileSystem](https://agentclientprotocol.com/protocol/initialization#filesystem)
struct FileSystemCapability: Codable {
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
}

/// An HTTP header to set when making requests to the MCP server.
struct HttpHeader: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The name of the HTTP header.
    let name: String
    /// The value to set for the HTTP header.
    let value: String
}

/// Metadata about the implementation of the client or agent.
/// Describes the name and version of an MCP implementation, with an optional
/// title for UI representation.
struct Implementation: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Intended for programmatic or logical use, but can be used as a display
    /// name fallback if title isn’t present.
    let name: String
    /// Intended for UI and end-user contexts — optimized to be human-readable
    /// and easily understood.
    ///
    /// If not provided, the name should be used for display.
    let title: String?
    /// Version of the implementation. Can be displayed to the user or used
    /// for debugging or metrics purposes. (e.g. "1.0.0").
    let version: String
}

/// Request parameters for the initialize method.
///
/// Sent by the client to establish connection and negotiate capabilities.
///
/// See protocol docs: [Initialization](https://agentclientprotocol.com/protocol/initialization)
struct InitializeRequest: Codable {
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
}

/// Response to the `initialize` method.
///
/// Contains the negotiated protocol version and agent capabilities.
///
/// See protocol docs: [Initialization](https://agentclientprotocol.com/protocol/initialization)
struct InitializeResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Capabilities supported by the agent.
    let agentCapabilities: AgentCapabilities?
    /// Information about the Agent name and version sent to the Client.
    ///
    /// Note: in future versions of the protocol, this will be required.
    let agentInfo: Implementation?
    /// Authentication methods supported by the agent.
    let authMethods: [AuthMethod]?
    /// The protocol version the client specified if supported by the agent,
    /// or the latest protocol version supported by the agent.
    ///
    /// The client should disconnect, if it doesn't support this version.
    let protocolVersion: ProtocolVersion
}

/// Request to kill a terminal command without releasing the terminal.
struct KillTerminalCommandRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The session ID for this request.
    let sessionId: SessionId
    /// The ID of the terminal to kill.
    let terminalId: String
}

/// Response to terminal/kill command method
struct KillTerminalCommandResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
}

/// Request parameters for loading an existing session.
///
/// Only available if the Agent supports the `loadSession` capability.
///
/// See protocol docs: [Loading Sessions](https://agentclientprotocol.com/protocol/session-setup#loading-sessions)
struct LoadSessionRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The working directory for this session.
    let cwd: String
    /// List of MCP servers to connect to for this session.
    let mcpServers: [McpServer]
    /// The ID of the session to load.
    let sessionId: SessionId
}

/// Response from loading an existing session.
struct LoadSessionResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Initial mode state if supported by the Agent
    ///
    /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
    let modes: SessionModeState?
}

/// MCP capabilities supported by the agent
struct McpCapabilities: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Agent supports [`McpServer::Http`].
    let http: Bool?
    /// Agent supports [`McpServer::Sse`].
    let sse: Bool?
}

/// HTTP transport configuration for MCP.
struct McpServerHttp: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// HTTP headers to set when making requests to the MCP server.
    let headers: [HttpHeader]
    /// Human-readable name identifying this MCP server.
    let name: String
    /// URL to the MCP server.
    let url: String
}

/// SSE transport configuration for MCP.
struct McpServerSse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// HTTP headers to set when making requests to the MCP server.
    let headers: [HttpHeader]
    /// Human-readable name identifying this MCP server.
    let name: String
    /// URL to the MCP server.
    let url: String
}

/// Stdio transport configuration for MCP.
struct McpServerStdio: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Command-line arguments to pass to the MCP server.
    let args: [String]
    /// Path to the MCP server executable.
    let command: String
    /// Environment variables to set when launching the MCP server.
    let env: [EnvVariable]
    /// Human-readable name identifying this MCP server.
    let name: String
}

enum McpServer: Codable {
    case http(McpServerHttp)
    case sse(McpServerSse)
    case mcpServerStdio(McpServerStdio)

    init(from decoder: Decoder) throws {
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
        throw DecodingError.typeMismatch(McpServer.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for McpServer"))
    }

    func encode(to encoder: Encoder) throws {
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
struct NewSessionRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The working directory for this session. Must be an absolute path.
    let cwd: String
    /// List of MCP (Model Context Protocol) servers the agent should connect to.
    let mcpServers: [McpServer]
}

/// Response from creating a new session.
///
/// See protocol docs: [Creating a Session](https://agentclientprotocol.com/protocol/session-setup#creating-a-session)
struct NewSessionResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Initial mode state if supported by the Agent
    ///
    /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
    let modes: SessionModeState?
    /// Unique identifier for the created session.
    ///
    /// Used in all subsequent requests for this conversation.
    let sessionId: SessionId
}

/// An option presented to the user when requesting permission.
struct PermissionOption: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Hint about the nature of this permission option.
    let kind: PermissionOptionKind
    /// Human-readable label to display to the user.
    let name: String
    /// Unique identifier for this permission option.
    let optionId: PermissionOptionId
}

typealias PermissionOptionId = String

enum PermissionOptionKind: String, Codable {
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
struct Plan: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The list of tasks to be accomplished.
    ///
    /// When updating a plan, the agent must send a complete list of all entries
    /// with their current status. The client replaces the entire plan with each update.
    let entries: [PlanEntry]
}

/// A single entry in the execution plan.
///
/// Represents a task or goal that the assistant intends to accomplish
/// as part of fulfilling the user's request.
/// See protocol docs: [Plan Entries](https://agentclientprotocol.com/protocol/agent-plan#plan-entries)
struct PlanEntry: Codable {
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
struct PromptCapabilities: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Agent supports [`ContentBlock::Audio`].
    let audio: Bool?
    /// Agent supports embedded context in `session/prompt` requests.
    ///
    /// When enabled, the Client is allowed to include [`ContentBlock::Resource`]
    /// in prompt requests for pieces of context that are referenced in the message.
    let embeddedContext: Bool?
    /// Agent supports [`ContentBlock::Image`].
    let image: Bool?
}

/// Request parameters for sending a user prompt to the agent.
///
/// Contains the user's message and any additional context.
///
/// See protocol docs: [User Message](https://agentclientprotocol.com/protocol/prompt-turn#1-user-message)
struct PromptRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
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
    let prompt: [ContentBlock]
    /// The ID of the session to send this user message to
    let sessionId: SessionId
}

/// Response from processing a user prompt.
///
/// See protocol docs: [Check for Completion](https://agentclientprotocol.com/protocol/prompt-turn#4-check-for-completion)
struct PromptResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Indicates why the agent stopped processing the turn.
    let stopReason: StopReason
}

typealias ProtocolVersion = Int

/// Request to read content from a text file.
///
/// Only available if the client supports the `fs.readTextFile` capability.
struct ReadTextFileRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Maximum number of lines to read.
    let limit: Int?
    /// Line number to start reading from (1-based).
    let line: Int?
    /// Absolute path to the file to read.
    let path: String
    /// The session ID for this request.
    let sessionId: SessionId
}

/// Response containing the contents of a text file.
struct ReadTextFileResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let content: String
}

/// Request to release a terminal and free its resources.
struct ReleaseTerminalRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The session ID for this request.
    let sessionId: SessionId
    /// The ID of the terminal to release.
    let terminalId: String
}

/// Response to terminal/release method
struct ReleaseTerminalResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
}

typealias RequestId = AnyCodable

/// The prompt turn was cancelled before the user responded.
///
/// When a client sends a `session/cancel` notification to cancel an ongoing
/// prompt turn, it MUST respond to all pending `session/request_permission`
/// requests with this `Cancelled` outcome.
///
/// See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/prompt-turn#cancellation)
struct RequestPermissionOutcomeOption1: Codable {
    let outcome: String
}

/// The user selected one of the provided options.
struct SelectedPermissionOutcome: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The ID of the option the user selected.
    let optionId: PermissionOptionId
}

enum RequestPermissionOutcome: Codable {
    case cancelled(RequestPermissionOutcomeOption1)
    case selected(SelectedPermissionOutcome)

    init(from decoder: Decoder) throws {
        if let key = _DiscriminatorCodingKey(stringValue: "outcome"),
           let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
           let raw = try? container.decode(String.self, forKey: key) {
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
        throw DecodingError.typeMismatch(RequestPermissionOutcome.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for RequestPermissionOutcome"))
    }

    func encode(to encoder: Encoder) throws {
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
struct RequestPermissionRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Available permission options for the user to choose from.
    let options: [PermissionOption]
    /// The session ID for this request.
    let sessionId: SessionId
    /// Details about the tool call requiring permission.
    let toolCall: ToolCallUpdate
}

/// Response to a permission request.
struct RequestPermissionResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The user's decision on the permission request.
    let outcome: RequestPermissionOutcome
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
struct SessionCapabilities: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
}

typealias SessionId = String

/// A mode the agent can operate in.
///
/// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
struct SessionMode: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let description: String?
    let id: SessionModeId
    let name: String
}

typealias SessionModeId = String

/// The set of modes and the one currently active.
struct SessionModeState: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The set of modes that the Agent can operate in
    let availableModes: [SessionMode]
    /// The current mode the Agent is in.
    let currentModeId: SessionModeId
}

/// Notification containing a session update from the agent.
///
/// Used to stream real-time progress and results during prompt processing.
///
/// See protocol docs: [Agent Reports Output](https://agentclientprotocol.com/protocol/prompt-turn#3-agent-reports-output)
struct SessionNotification: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The ID of the session this update pertains to.
    let sessionId: SessionId
    /// The actual update content.
    let update: SessionUpdate
}

/// Represents a tool call that the language model has requested.
///
/// Tool calls are actions that the agent executes on behalf of the language model,
/// such as reading files, executing code, or fetching data from external sources.
///
/// See protocol docs: [Tool Calls](https://agentclientprotocol.com/protocol/tool-calls)
struct ToolCall: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Content produced by the tool call.
    let content: [ToolCallContent]?
    /// The category of tool being invoked.
    /// Helps clients choose appropriate icons and UI treatment.
    let kind: ToolKind?
    /// File locations affected by this tool call.
    /// Enables "follow-along" features in clients.
    let locations: [ToolCallLocation]?
    /// Raw input parameters sent to the tool.
    let rawInput: AnyCodable?
    /// Raw output returned by the tool.
    let rawOutput: AnyCodable?
    /// Current execution status of the tool call.
    let status: ToolCallStatus?
    /// Human-readable title describing what the tool is doing.
    let title: String
    /// Unique identifier for this tool call within the session.
    let toolCallId: ToolCallId
}

/// An update to an existing tool call.
///
/// Used to report progress and results as tools execute. All fields except
/// the tool call ID are optional - only changed fields need to be included.
///
/// See protocol docs: [Updating](https://agentclientprotocol.com/protocol/tool-calls#updating)
struct ToolCallUpdate: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Replace the content collection.
    let content: [ToolCallContent]?
    /// Update the tool kind.
    let kind: ToolKind?
    /// Replace the locations collection.
    let locations: [ToolCallLocation]?
    /// Update the raw input.
    let rawInput: AnyCodable?
    /// Update the raw output.
    let rawOutput: AnyCodable?
    /// Update the execution status.
    let status: ToolCallStatus?
    /// Update the human-readable title.
    let title: String?
    /// The ID of the tool call being updated.
    let toolCallId: ToolCallId
}

enum SessionUpdate: Codable {
    case user_message_chunk(ContentChunk)
    case agent_message_chunk(ContentChunk)
    case agent_thought_chunk(ContentChunk)
    case tool_call(ToolCall)
    case tool_call_update(ToolCallUpdate)
    case plan(Plan)
    case available_commands_update(AvailableCommandsUpdate)
    case current_mode_update(CurrentModeUpdate)

    init(from decoder: Decoder) throws {
        if let key = _DiscriminatorCodingKey(stringValue: "sessionUpdate"),
           let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
           let raw = try? container.decode(String.self, forKey: key) {
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
        throw DecodingError.typeMismatch(SessionUpdate.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for SessionUpdate"))
    }

    func encode(to encoder: Encoder) throws {
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

enum StopReason: String, Codable {
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
struct Terminal: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    let terminalId: String
}

/// Exit status of a terminal command.
struct TerminalExitStatus: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The process exit code (may be null if terminated by signal).
    let exitCode: Int?
    /// The signal that terminated the process (may be null if exited normally).
    let signal: String?
}

/// Request to get the current output and status of a terminal.
struct TerminalOutputRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The session ID for this request.
    let sessionId: SessionId
    /// The ID of the terminal to get output from.
    let terminalId: String
}

/// Response containing the terminal output and exit status.
struct TerminalOutputResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Exit status if the command has completed.
    let exitStatus: TerminalExitStatus?
    /// The terminal output captured so far.
    let output: String
    /// Whether the output was truncated due to byte limits.
    let truncated: Bool
}

enum ToolCallContent: Codable {
    case content(Content)
    case diff(Diff)
    case terminal(Terminal)

    init(from decoder: Decoder) throws {
        if let key = _DiscriminatorCodingKey(stringValue: "type"),
           let container = try? decoder.container(keyedBy: _DiscriminatorCodingKey.self),
           let raw = try? container.decode(String.self, forKey: key) {
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
        throw DecodingError.typeMismatch(ToolCallContent.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for ToolCallContent"))
    }

    func encode(to encoder: Encoder) throws {
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

typealias ToolCallId = String

/// A file location being accessed or modified by a tool.
///
/// Enables clients to implement "follow-along" features that track
/// which files the agent is working with in real-time.
///
/// See protocol docs: [Following the Agent](https://agentclientprotocol.com/protocol/tool-calls#following-the-agent)
struct ToolCallLocation: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// Optional line number within the file.
    let line: Int?
    /// The file path being accessed or modified.
    let path: String
}

enum ToolCallStatus: String, Codable {
    case pending = "pending"
    case in_progress = "in_progress"
    case completed = "completed"
    case failed = "failed"
}

enum ToolKind: String, Codable {
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
struct WaitForTerminalExitRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The session ID for this request.
    let sessionId: SessionId
    /// The ID of the terminal to wait for.
    let terminalId: String
}

/// Response containing the exit status of a terminal command.
struct WaitForTerminalExitResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The process exit code (may be null if terminated by signal).
    let exitCode: Int?
    /// The signal that terminated the process (may be null if exited normally).
    let signal: String?
}

/// Request to write content to a text file.
///
/// Only available if the client supports the `fs.writeTextFile` capability.
struct WriteTextFileRequest: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
    /// The text content to write to the file.
    let content: String
    /// Absolute path to the file to write.
    let path: String
    /// The session ID for this request.
    let sessionId: SessionId
}

/// Response to `fs/write_text_file`
struct WriteTextFileResponse: Codable {
    /// The _meta property is reserved by ACP to allow clients and agents to attach additional
    /// metadata to their interactions. Implementations MUST NOT make assumptions about values at
    /// these keys.
    ///
    /// See protocol docs: [Extensibility](https://agentclientprotocol.com/protocol/extensibility)
    let _meta: [String: AnyCodable]?
}

enum AgentNotificationParams: Codable {
    case sessionNotification(SessionNotification)
    case extNotification(ExtNotification)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(SessionNotification.self) {
            self = .sessionNotification(value)
            return
        }
        if let value = try? container.decode(ExtNotification.self) {
            self = .extNotification(value)
            return
        }
        throw DecodingError.typeMismatch(AgentNotificationParams.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for AgentNotificationParams"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .sessionNotification(let value):
            try container.encode(value)
        case .extNotification(let value):
            try container.encode(value)
        }
    }
}

enum AgentRequestParams: Codable {
    case writeTextFileRequest(WriteTextFileRequest)
    case readTextFileRequest(ReadTextFileRequest)
    case requestPermissionRequest(RequestPermissionRequest)
    case createTerminalRequest(CreateTerminalRequest)
    case terminalOutputRequest(TerminalOutputRequest)
    case releaseTerminalRequest(ReleaseTerminalRequest)
    case waitForTerminalExitRequest(WaitForTerminalExitRequest)
    case killTerminalCommandRequest(KillTerminalCommandRequest)
    case extRequest(ExtRequest)

    init(from decoder: Decoder) throws {
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
        throw DecodingError.typeMismatch(AgentRequestParams.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for AgentRequestParams"))
    }

    func encode(to encoder: Encoder) throws {
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
        throw DecodingError.typeMismatch(ResultOption.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for ResultOption"))
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
        throw DecodingError.typeMismatch(ClientNotificationParams.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for ClientNotificationParams"))
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
        throw DecodingError.typeMismatch(ClientRequestParams.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching type for ClientRequestParams"))
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
enum Role: String, Codable {
    case assistant = "assistant"
    case user = "user"
}

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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
