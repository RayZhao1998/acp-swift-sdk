import Foundation

public protocol Agent: Actor {
  /// Establishes the connection with a client and negotiates protocol capabilities.
  ///
  /// This method is called once at the beginning of the connection to:
  /// - Negotiate the protocol version to use
  /// - Exchange capability information between client and agent
  /// - Determine available authentication methods
  ///
  /// The agent should respond with its supported protocol version and capabilities.
  ///
  /// See protocol docs: [Initialization](https://agentclientprotocol.com/protocol/initialization)
  func initialize(
    _ params: InitializeRequest
  ) async throws -> InitializeResponse

  /// Creates a new conversation session with the agent.
  ///
  /// Sessions represent independent conversation contexts with their own history and state.
  ///
  /// The agent should:
  /// - Create a new session context
  /// - Connect to any specified MCP servers
  /// - Return a unique session ID for future requests
  ///
  /// May return an `auth_required` error if the agent requires authentication.
  ///
  /// See protocol docs: [Session Setup](https://agentclientprotocol.com/protocol/session-setup)
  func newSession(
    _ params: NewSessionRequest
  ) async throws -> NewSessionResponse

  /// Processes a user prompt within a session.
  ///
  /// This method handles the whole lifecycle of a prompt:
  /// - Receives user messages with optional context (files, images, etc.)
  /// - Processes the prompt using language models
  /// - Reports language model content and tool calls to the Clients
  /// - Requests permission to run tools
  /// - Executes any requested tool calls
  /// - Returns when the turn is complete with a stop reason
  ///
  /// See protocol docs: [Prompt Turn](https://agentclientprotocol.com/protocol/prompt-turn)
  func prompt(
    _ params: PromptRequest
  ) async throws -> PromptResponse

  /// Cancels ongoing operations for a session.
  ///
  /// This is a notification sent by the client to cancel an ongoing prompt turn.
  ///
  /// Upon receiving this notification, the Agent SHOULD:
  /// - Stop all language model requests as soon as possible
  /// - Abort all tool call invocations in progress
  /// - Send any pending `session/update` notifications
  /// - Respond to the original `session/prompt` request with `StopReason::Cancelled`
  ///
  /// See protocol docs: [Cancellation](https://agentclientprotocol.com/protocol/prompt-turn#cancellation)
  func cancel(
    _ params: CancelNotification
  ) async throws

  /// Authenticates the client using the specified authentication method.
  ///
  /// Called when the agent requires authentication before allowing session creation.
  /// The client provides the authentication method ID that was advertised during initialization.
  ///
  /// After successful authentication, the client can proceed to create sessions with
  /// `newSession` without receiving an `auth_required` error.
  ///
  /// See protocol docs: [Initialization](https://agentclientprotocol.com/protocol/initialization)
  func authenticate(
    _ params: AuthenticateRequest
  ) async throws -> AuthenticateResponse
}

extension Agent {
  /// Loads an existing session to resume a previous conversation.
  ///
  /// This method is only available if the agent advertises the `loadSession` capability.
  ///
  /// The agent should:
  /// - Restore the session context and conversation history
  /// - Connect to the specified MCP servers
  /// - Stream the entire conversation history back to the client via notifications
  ///
  /// See protocol docs: [Loading Sessions](https://agentclientprotocol.com/protocol/session-setup#loading-sessions)
  public func loadSession(
    _ params: LoadSessionRequest
  ) async throws -> LoadSessionResponse {
    throw ACPError.methodNotFound(AgentMethod.sessionLoad.rawValue)
  }

  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Forks an existing session to create a new independent session.
  ///
  /// Creates a new session based on the context of an existing one, allowing
  /// operations like generating summaries without affecting the original session's history.
  ///
  /// This method is only available if the agent advertises the `session.fork` capability.
  ///
  /// @experimental
  ///
  public func forkSession(
    _ params: ForkSessionRequest,
  ) async throws -> ForkSessionResponse {
    throw ACPError.methodNotFound(AgentMethod.sessionFork.rawValue)
  }

  ///
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Lists existing sessions from the agent.
  ///
  /// This method is only available if the agent advertises the `listSessions` capability.
  ///
  /// Returns a list of sessions with metadata like session ID, working directory,
  /// title, and last update time. Supports filtering by working directory and
  /// cursor-based pagination.
  ///
  public func listSessions(
    _ params: ListSessionsRequest,
  ) async throws -> ListSessionsResponse {
    throw ACPError.methodNotFound(AgentMethod.sessionList.rawValue)
  }

  ///
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Resumes an existing session without returning previous messages.
  ///
  /// This method is only available if the agent advertises the `session.resume` capability.
  ///
  /// The agent should resume the session context, allowing the conversation to continue
  /// without replaying the message history (unlike `session/load`).
  ///
  /// @experimental
  ///
  public func resumeSession(
    _ params: ResumeSessionRequest,
  ) async throws -> ResumeSessionResponse {
    throw ACPError.methodNotFound(AgentMethod.sessionResume.rawValue)
  }

  /// Sets the operational mode for a session.
  ///
  /// Allows switching between different agent modes (e.g., "ask", "architect", "code")
  /// that affect system prompts, tool availability, and permission behaviors.
  ///
  /// The mode must be one of the modes advertised in `availableModes` during session
  /// creation or loading. Agents may also change modes autonomously and notify the
  /// client via `current_mode_update` notifications.
  ///
  /// This method can be called at any time during a session, whether the Agent is
  /// idle or actively generating a turn.
  ///
  /// See protocol docs: [Session Modes](https://agentclientprotocol.com/protocol/session-modes)
  func setSessionMode(
    _ params: SetSessionModeRequest
  ) async throws -> SetSessionModeResponse {
    throw ACPError.methodNotFound(AgentMethod.sessionSetMode.rawValue)
  }

  ///
  /// **UNSTABLE**
  ///
  /// This capability is not part of the spec yet, and may be removed or changed at any point.
  ///
  /// Select a model for a given session.
  ///
  /// @experimental
  ///
  public func setSessionModel(
    _ params: SetSessionModelRequest,
  ) async throws -> SetSessionModelResponse {
    throw ACPError.methodNotFound(AgentMethod.sessionSetModel.rawValue)
  }

  ///
  /// Extension method
  ///
  /// Allows the Client to send an arbitrary request that is not part of the ACP spec.
  ///
  /// To help avoid conflicts, it's a good practice to prefix extension
  /// methods with a unique identifier such as domain name.
  ///
  public func extMethod(
    method: String,
    params: AnyCodable,
  ) async throws -> AnyCodable {
    throw ACPError.methodNotFound(method)
  }

  ///
  /// Extension notification
  ///
  /// Allows the Client to send an arbitrary notification that is not part of the ACP spec.
  ///
  public func extNotification(
    method: String,
    params: AnyCodable,
  ) async throws {
    throw ACPError.methodNotFound(method)
  }
}
