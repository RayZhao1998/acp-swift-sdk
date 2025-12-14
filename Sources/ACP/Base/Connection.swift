import Foundation

struct JSONRPCRemoteError: Error, Sendable {
  let error: JSONRPCError
}

public actor Connection: Sendable {
  typealias RequestHandler = @Sendable (String, AnyCodable?) async throws -> Any?
  typealias NotificationHandler = @Sendable (String, AnyCodable?) async throws -> Void

  private let requestHandler: RequestHandler
  private let notificationHandler: NotificationHandler
  private let stream: MessageStream

  private var nextRequestId: Int = 0
  private var pendingResponses: [String: CheckedContinuation<JSONRPCSuccessResponse, Error>] = [:]

  private var isClosed: Bool = false
  private var closedContinuation: CheckedContinuation<Void, Never>?

  init(
    requestHandler: @escaping RequestHandler,
    notificationHandler: @escaping NotificationHandler,
    stream: MessageStream
  ) {
    self.requestHandler = requestHandler
    self.notificationHandler = notificationHandler
    self.stream = stream
    Task {
      await self.receiveLoop()
    }
  }

  private func receiveLoop() async {
    do {
      while let message = try await stream.read() {
        await handle(message)
      }
    } catch {

    }

    await close()
  }

  private func handle(_ message: JSONRPCMessage) async {
    switch message {
    case .request(let req):
      let response = await handleRequest(req)
      try? await stream.write(.response(response))
    case .response(let resp):
      handleResponse(resp)
    case .notification(let notif):
      try? await notificationHandler(notif.method, notif.params)
    }
  }

  private func handleRequest(_ request: JSONRPCRequest) async -> JSONRPCResponse {
    do {
      let result = try await requestHandler(request.method, request.params)
      let successResponse = JSONRPCSuccessResponse(
        id: request.id,
        result: AnyCodable(result as Any)
      )
      return .success(successResponse)
    } catch {
      let rpcError = JSONRPCError(
        code: .init(-32000), data: nil, message: error.localizedDescription)
      let errorResponse = JSONRPCErrorResponse(id: request.id, error: rpcError)
      return .failure(errorResponse)
    }
  }

  private func handleResponse(_ response: JSONRPCResponse) {
    switch response {
    case .success(let successResponse):
      let id = successResponse.id
      guard let cont = pendingResponses.removeValue(forKey: id) else {
        return
      }
      cont.resume(returning: successResponse)
    case .failure(let failureResponse):
      let id = failureResponse.id
      guard let cont = pendingResponses.removeValue(forKey: id) else {
        return
      }
      cont.resume(throwing: JSONRPCRemoteError(error: failureResponse.error))
    }
  }

  func sendRequest<T: Decodable>(method: String, params: Any? = nil) async throws -> T {
    let id = nextRequestId
    nextRequestId += 1

    let message = JSONRPCMessage.request(
      JSONRPCRequest(id: "\(id)", method: method, params: params))

    let successResponse = try await withCheckedThrowingContinuation { cont in
      pendingResponses["\(id)"] = cont
      Task {
        try await stream.write(message)
      }
    }

    return try decodeResult(successResponse.result)
  }

  private func decodeResult<T: Decodable>(_ result: AnyCodable) throws -> T {
    let data = try JSONEncoder().encode(result)
    return try JSONDecoder().decode(T.self, from: data)
  }

  func sendNotification(
    method: String,
    params: Any? = nil
  ) async throws {
    let message = JSONRPCMessage.notification(
      JSONRPCNotification(method: method, params: params)
    )
    try await stream.write(message)
  }

  func close() async {
    guard !isClosed else { return }
    isClosed = true

    for (_, cont) in pendingResponses {
      cont.resume(throwing: CancellationError())
    }
    pendingResponses.removeAll()

    closedContinuation?.resume()
  }

  var closed: Void {
    get async {
      await withCheckedContinuation { cont in
        if isClosed {
          cont.resume()
        } else {
          closedContinuation = cont
        }
      }
    }
  }
}
