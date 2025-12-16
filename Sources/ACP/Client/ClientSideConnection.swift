import Foundation

public actor ClientSideConnection: Agent {
  private let toClient: (Agent) -> Client
  private let stream: MessageStream
  private lazy var client: Client = toClient(self)
  private lazy var connection: Connection = {
    let requestHandler: Connection.RequestHandler = { method, params in
      switch method {
      case ClientMethod.sessionRequestPermission.rawValue:
        let decodedParams = try JSONDecoder().decode(
          RequestPermissionRequest.self, from: JSONEncoder().encode(params))
        return try await self.client.requestPermission(params: decodedParams)
      case ClientMethod.fsWriteTextFile.rawValue:
        let decodedParams = try JSONDecoder().decode(
          WriteTextFileRequest.self, from: JSONEncoder().encode(params))
        return try await self.client.writeTextFile(params: decodedParams)
      case ClientMethod.fsReadTextFile.rawValue:
        let decodedParams = try JSONDecoder().decode(
          ReadTextFileRequest.self, from: JSONEncoder().encode(params))
        return try await self.client.readTextFile(params: decodedParams)
      case ClientMethod.terminalCreate.rawValue:
        let decodedParams = try JSONDecoder().decode(
          CreateTerminalRequest.self, from: JSONEncoder().encode(params))
        return try await self.client.createTerminal(params: decodedParams)
      case ClientMethod.terminalOutput.rawValue:
        let decodedParams = try JSONDecoder().decode(
          TerminalOutputRequest.self,
          from: JSONEncoder()
            .encode(params))
        return try await self.client.terminalOutput(params: decodedParams)
      case ClientMethod.terminalRelease.rawValue:
        let decodedParams = try JSONDecoder().decode(
          ReleaseTerminalRequest.self,
          from: JSONEncoder()
            .encode(params))
        return try await self.client.releaseTerminal(params: decodedParams)
      case ClientMethod.terminalWaitForExit.rawValue:
        let decodedParams = try JSONDecoder().decode(
          WaitForTerminalExitRequest.self,
          from: JSONEncoder()
            .encode(params))
        return try await self.client.waitForTerminalExit(params: decodedParams)
      case ClientMethod.terminalKill.rawValue:
        let decodedParams = try JSONDecoder().decode(
          KillTerminalCommandRequest.self,
          from: JSONEncoder()
            .encode(params))
        return try await self.client.killTerminal(params: decodedParams)
      default:
        throw ACPError.methodNotFound(method)
      }
    }

    let notificationHandler: Connection.NotificationHandler = { method, params in
      switch method {
      case ClientMethod.sessionUpdate.rawValue:
        let decodedParams = try JSONDecoder().decode(
          SessionNotification.self, from: JSONEncoder().encode(params))
        try await self.client.sessionUpdate(params: decodedParams)
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
