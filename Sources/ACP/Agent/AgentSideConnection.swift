import Foundation

public actor AgentSideConnection: Client {
  private let toAgent: (Client) -> Agent
  private let stream: MessageStream
  private lazy var agent: Agent = toAgent(self)
  private lazy var connection: Connection = {
    let requestHandler: Connection.RequestHandler = { method, params in
      switch method {
      case AgentMethod.authenticate.rawValue:
        let decodedParams = try JSONDecoder().decode(
          AuthenticateRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.authenticate(decodedParams)
      case AgentMethod.initialize.rawValue:
        let decodedParams = try JSONDecoder().decode(
          InitializeRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.initialize(decodedParams)
      case AgentMethod.sessionFork.rawValue:
        let decodedParams = try JSONDecoder().decode(
          ForkSessionRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.forkSession(decodedParams)
      case AgentMethod.sessionList.rawValue:
        let decodedParams = try JSONDecoder().decode(
          ListSessionsRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.listSessions(decodedParams)
      case AgentMethod.sessionLoad.rawValue:
        let decodedParams = try JSONDecoder().decode(
          LoadSessionRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.loadSession(decodedParams)
      case AgentMethod.sessionNew.rawValue:
        let decodedParams = try JSONDecoder().decode(
          NewSessionRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.newSession(decodedParams)
      case AgentMethod.sessionResume.rawValue:
        let decodedParams = try JSONDecoder().decode(
          ResumeSessionRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.resumeSession(decodedParams)
      case AgentMethod.sessionPrompt.rawValue:
        let decodedParams = try JSONDecoder().decode(
          PromptRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.prompt(decodedParams)
      case AgentMethod.sessionSetMode.rawValue:
        let decodedParams = try JSONDecoder().decode(
          SetSessionModeRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.setSessionMode(decodedParams)
      case AgentMethod.sessionSetModel.rawValue:
        let decodedParams = try JSONDecoder().decode(
          SetSessionModelRequest.self, from: JSONEncoder().encode(params))
        return try await self.agent.setSessionModel(decodedParams)
      default:
        throw ACPError.methodNotFound(method)
      }
    }

    let notificationHandler: Connection.NotificationHandler = { method, params in
      switch method {
      case AgentMethod.sessionCancel.rawValue:
        let decodedParams = try JSONDecoder().decode(
          CancelNotification.self, from: JSONEncoder().encode(params))
        try await self.agent.cancel(decodedParams)
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
