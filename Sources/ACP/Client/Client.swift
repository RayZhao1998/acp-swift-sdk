import Foundation

public protocol Client: Actor {

  /// Requests permission from the user for a tool call operation.
  ///
  /// Called by the agent when it needs user authorization before executing
  /// a potentially sensitive operation. The client should present the options
  /// to the user and return their decision.
  ///
  /// If the client cancels the prompt turn via `session/cancel`, it MUST
  /// respond to this request with `RequestPermissionOutcome::Cancelled`.
  ///
  /// See protocol docs: [Requesting Permission](https://agentclientprotocol.com/protocol/tool-calls#requesting-permission)
  func requestPermission(params: RequestPermissionRequest) async throws
    -> RequestPermissionResponse

  /// Handles session update notifications from the agent.
  ///
  /// This is a notification endpoint (no response expected) that receives
  /// real-time updates about session progress, including message chunks,
  /// tool calls, and execution plans.
  ///
  /// Note: Clients SHOULD continue accepting tool call updates even after
  /// sending a `session/cancel` notification, as the agent may send final
  /// updates before responding with the cancelled stop reason.
  ///
  /// See protocol docs: [Agent Reports Output](https://agentclientprotocol.com/protocol/prompt-turn#3-agent-reports-output)
  func sessionUpdate(params: SessionNotification) async throws
}

extension Client {
  /// Writes content to a text file in the client's file system.
  ///
  /// Only available if the client advertises the `fs.writeTextFile` capability.
  /// Allows the agent to create or modify files within the client's environment.
  ///
  /// See protocol docs: [Client](https://agentclientprotocol.com/protocol/overview#client)
  public func writeTextFile(params: WriteTextFileRequest) async throws -> WriteTextFileResponse {
    throw ACPError.methodNotFound("writeTextFile")
  }

  /// Reads content from a text file in the client's file system.
  ///
  /// Only available if the client advertises the `fs.readTextFile` capability.
  /// Allows the agent to access file contents within the client's environment.
  ///
  /// See protocol docs: [Client](https://agentclientprotocol.com/protocol/overview#client)
  public func readTextFile(params: ReadTextFileRequest) async throws -> ReadTextFileResponse {
    throw ACPError.methodNotFound("readTextFile")
  }

  /// Creates a new terminal to execute a command.
  ///
  /// Only available if the `terminal` capability is set to `true`.
  ///
  /// The Agent must call `releaseTerminal` when done with the terminal
  /// to free resources.
  ///
  /// See protocol docs: [Terminal Documentation](https://agentclientprotocol.com/protocol/terminals)
  public func createTerminalSession(params: CreateTerminalRequest) async throws
    -> CreateTerminalResponse
  {
    throw ACPError.methodNotFound("createTerminalSession")
  }

  /// Gets the current output and exit status of a terminal.
  ///
  /// Returns immediately without waiting for the command to complete.
  /// If the command has already exited, the exit status is included.
  ///
  /// See protocol docs: [Getting Terminal Output](https://agentclientprotocol.com/protocol/terminals#getting-output)
  public func terminalOutput(params: TerminalOutputRequest) async throws -> TerminalOutputResponse {
    throw ACPError.methodNotFound("terminalOutput")
  }

  /// Releases a terminal and frees all associated resources.
  ///
  /// The command is killed if it hasn't exited yet. After release,
  /// the terminal ID becomes invalid for all other terminal methods.
  ///
  /// Tool calls that already contain the terminal ID continue to
  /// display its output.
  ///
  /// See protocol docs: [Releasing Terminals](https://agentclientprotocol.com/protocol/terminals#releasing-terminals)
  public func releaseTerminal(params: ReleaseTerminalRequest) async throws
    -> ReleaseTerminalResponse
  {
    throw ACPError.methodNotFound("releaseTerminal")
  }

  /// Waits for a terminal command to exit and returns its exit status.
  ///
  /// This method returns once the command completes, providing the
  /// exit code and/or signal that terminated the process.
  ///
  /// See protocol docs: [Waiting for Exit](https://agentclientprotocol.com/protocol/terminals#waiting-for-exit)
  public func waitForTerminalExit(params: WaitForTerminalExitRequest) async throws
    -> WaitForTerminalExitResponse
  {
    throw ACPError.methodNotFound("waitForTerminalExit")
  }

  /// Kills a terminal command without releasing the terminal.
  ///
  /// While `releaseTerminal` also kills the command, this method keeps
  /// the terminal ID valid so it can be used with other methods.
  ///
  /// Useful for implementing command timeouts that terminate the command
  /// and then retrieve the final output.
  ///
  /// Note: Call `releaseTerminal` when the terminal is no longer needed.
  ///
  /// See protocol docs: [Killing Commands](https://agentclientprotocol.com/protocol/terminals#killing-commands)
  public func killTerminal(params: KillTerminalCommandRequest) async throws
    -> KillTerminalCommandResponse
  {
    throw ACPError.methodNotFound("killTerminal")
  }

  /// Extension method
  ///
  /// Allows the Agent to send an arbitrary request that is not part of the ACP spec.
  ///
  /// To help avoid conflicts, it's a good practice to prefix extension
  /// methods with a unique identifier such as domain name.
  public func extMethod(method: String, params: [String: AnyCodable]) async throws
    -> [String: AnyCodable]
  {
    throw ACPError.methodNotFound("extMethod")
  }

  /// Extension notification
  ///
  /// Allows the Agent to send an arbitrary notification that is not part of the ACP spec.
  public func extNotification(method: String, params: [String: AnyCodable]) async throws {
    throw ACPError.methodNotFound("extNotification")
  }
}
