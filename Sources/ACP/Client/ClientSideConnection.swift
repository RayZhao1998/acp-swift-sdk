import Foundation

public actor ClientSideConnection: Agent {
  private let toClient: (Agent) -> Client
  private let stream: MessageStream
  private lazy var client: Client = toClient(self)
  private lazy var connection: Connection = {
    let requestHandler: Connection.RequestHandler = { method, params in
      switch method {
      case ClientMethod.sessionRequestPermission.rawValue:
        return try await self.client.requestPermission(
          params: decodeParams(params, as: RequestPermissionRequest.self))
      case ClientMethod.fsWriteTextFile.rawValue:
        return try await self.client.writeTextFile(
          params: decodeParams(params, as: WriteTextFileRequest.self))
      case ClientMethod.fsReadTextFile.rawValue:
        return try await self.client.readTextFile(
          params: decodeParams(params, as: ReadTextFileRequest.self))
      case ClientMethod.terminalCreate.rawValue:
        return try await self.client.createTerminal(
          params: decodeParams(params, as: CreateTerminalRequest.self))
      case ClientMethod.terminalOutput.rawValue:
        return try await self.client.terminalOutput(
          params: decodeParams(params, as: TerminalOutputRequest.self))
      case ClientMethod.terminalRelease.rawValue:
        return try await self.client.releaseTerminal(
          params: decodeParams(params, as: ReleaseTerminalRequest.self))
      case ClientMethod.terminalWaitForExit.rawValue:
        return try await self.client.waitForTerminalExit(
          params: decodeParams(params, as: WaitForTerminalExitRequest.self))
      case ClientMethod.terminalKill.rawValue:
        return try await self.client.killTerminal(
          params: decodeParams(params, as: KillTerminalCommandRequest.self))
      default:
        throw ACPError.methodNotFound(method)
      }
    }

    let notificationHandler: Connection.NotificationHandler = { method, params in
      switch method {
      case ClientMethod.sessionUpdate.rawValue:
        try await self.client.sessionUpdate(params: decodeParams(params, as: SessionNotification.self))
      default:
        break
      }
    }

    return Connection(
      requestHandler: requestHandler,
      notificationHandler: notificationHandler,
      stream: stream)
  }()

  public init(toClient: @escaping (Agent) -> Client, stream: MessageStream) {
    self.toClient = toClient
    self.stream = stream
  }

  public func initialize(_ params: InitializeRequest) async throws -> InitializeResponse {
    try await connection.sendRequest(method: AgentMethod.initialize.rawValue, params: params)
  }

  public func newSession(_ params: NewSessionRequest) async throws -> NewSessionResponse {
    try await connection.sendRequest(method: AgentMethod.sessionNew.rawValue, params: params)
  }

  public func loadSession(_ params: LoadSessionRequest) async throws -> LoadSessionResponse {
    try await connection.sendRequest(method: AgentMethod.sessionLoad.rawValue, params: params)
  }

  public func prompt(_ params: PromptRequest) async throws -> PromptResponse {
    try await connection.sendRequest(method: AgentMethod.sessionPrompt.rawValue, params: params)
  }

  public func cancel(_ params: CancelNotification) async throws {
    try await connection.sendNotification(
      method: AgentMethod.sessionCancel.rawValue, params: params)
  }

  public func authenticate(_ params: AuthenticateRequest) async throws -> AuthenticateResponse {
    try await connection.sendRequest(method: AgentMethod.authenticate.rawValue, params: params)
  }
}
