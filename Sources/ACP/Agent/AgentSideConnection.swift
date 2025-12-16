import Foundation

public actor AgentSideConnection: Client {
  private let toAgent: (Client) -> Agent
  private let stream: MessageStream
  private lazy var agent: Agent = toAgent(self)
  private lazy var connection: Connection = {
    let requestHandler: Connection.RequestHandler = { method, params in
      switch method {
      case AgentMethod.authenticate.rawValue:
        return try await self.agent.authenticate(
          decodeParams(params, as: AuthenticateRequest.self))
      case AgentMethod.initialize.rawValue:
        return try await self.agent.initialize(decodeParams(params, as: InitializeRequest.self))
      case AgentMethod.sessionFork.rawValue:
        return try await self.agent.forkSession(decodeParams(params, as: ForkSessionRequest.self))
      case AgentMethod.sessionList.rawValue:
        return try await self.agent.listSessions(decodeParams(params, as: ListSessionsRequest.self))
      case AgentMethod.sessionLoad.rawValue:
        return try await self.agent.loadSession(decodeParams(params, as: LoadSessionRequest.self))
      case AgentMethod.sessionNew.rawValue:
        return try await self.agent.newSession(decodeParams(params, as: NewSessionRequest.self))
      case AgentMethod.sessionResume.rawValue:
        return try await self.agent.resumeSession(
          decodeParams(params, as: ResumeSessionRequest.self))
      case AgentMethod.sessionPrompt.rawValue:
        return try await self.agent.prompt(decodeParams(params, as: PromptRequest.self))
      case AgentMethod.sessionSetMode.rawValue:
        return try await self.agent.setSessionMode(
          decodeParams(params, as: SetSessionModeRequest.self))
      case AgentMethod.sessionSetModel.rawValue:
        return try await self.agent.setSessionModel(
          decodeParams(params, as: SetSessionModelRequest.self))
      default:
        throw ACPError.methodNotFound(method)
      }
    }

    let notificationHandler: Connection.NotificationHandler = { method, params in
      switch method {
      case AgentMethod.sessionCancel.rawValue:
        try await self.agent.cancel(decodeParams(params, as: CancelNotification.self))
      default:
        throw ACPError.methodNotFound(method)
      }
    }

    return Connection(
      requestHandler: requestHandler, notificationHandler: notificationHandler, stream: stream)
  }()

  public init(toAgent: @escaping (Client) -> Agent, stream: MessageStream) {
    self.toAgent = toAgent
    self.stream = stream
  }

  public func requestPermission(params: RequestPermissionRequest) async throws
    -> RequestPermissionResponse
  {
    try await connection.sendRequest(
      method: ClientMethod.sessionRequestPermission.rawValue, params: params)
  }

  public func sessionUpdate(params: SessionNotification) async throws {
    try await connection.sendNotification(
      method: ClientMethod.sessionUpdate.rawValue, params: params)
  }
}
