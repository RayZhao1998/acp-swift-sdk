import Foundation

private let jsonrpcVersion = "2.0"

public struct JSONRPCRequest: Codable, Sendable {
  let jsonrpc: String
  let id: String
  let method: String
  let params: AnyCodable?

  init(id: String, method: String, params: Any?) {
    self.jsonrpc = jsonrpcVersion
    self.id = id
    self.method = method
    if let params = params {
      self.params = AnyCodable(params)
    } else {
      self.params = nil
    }
  }
}

public struct JSONRPCSuccessResponse: Codable, Sendable {
  let jsonrpc: String
  let id: String
  let result: AnyCodable
  init(id: String, result: AnyCodable) {
    self.jsonrpc = jsonrpcVersion
    self.id = id
    self.result = result
  }
}

public struct JSONRPCErrorResponse: Codable, Sendable {
  public let jsonrpc: String
  public let id: String
  public let error: JSONRPCError

  init(id: String, error: JSONRPCError) {
    self.jsonrpc = jsonrpcVersion
    self.id = id
    self.error = error
  }
}

public enum JSONRPCResponse: Decodable, Sendable {
  case success(JSONRPCSuccessResponse)
  case failure(JSONRPCErrorResponse)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let success = try? container.decode(JSONRPCSuccessResponse.self) {
      self = .success(success)
    } else {
      let error = try container.decode(JSONRPCErrorResponse.self)
      self = .failure(error)
    }
  }
}

public struct JSONRPCNotification: Codable, Sendable {
  let jsonrpc: String
  let method: String
  let params: AnyCodable?

  init(method: String, params: Any?) {
    self.jsonrpc = jsonrpcVersion
    self.method = method
    if let params = params {
      self.params = AnyCodable(params)
    } else {
      self.params = nil
    }
  }
}

public enum JSONRPCMessage: Decodable, Sendable {
  case request(JSONRPCRequest)
  case response(JSONRPCResponse)
  case notification(JSONRPCNotification)  // Added notification case

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let request = try? container.decode(JSONRPCRequest.self) {
      self = .request(request)
    } else if let response = try? container.decode(JSONRPCResponse.self) {
      self = .response(response)
    } else if let notification = try? container.decode(JSONRPCNotification.self) {
      self = .notification(notification)
    } else {
      throw DecodingError.typeMismatch(
        JSONRPCMessage.self,
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Unsupported JSON-RPC message"))
    }
  }
}
