import Foundation

public enum ACPError: Error, Sendable {
  case parseError(String?)
  case invalidRequest(String?)
  case methodNotFound(String?)
  case invalidParams(String?)
  case internalError(String?)
  case authRequired(String?)
  case resourceNotFound(String?)

  public var code: Int {
    switch self {
    case .parseError:
      return -32700
    case .invalidRequest:
      return -32600
    case .methodNotFound:
      return -32601
    case .invalidParams:
      return -32602
    case .internalError:
      return -32603
    case .authRequired:
      return -32000
    case .resourceNotFound:
      return -32002
    }
  }
}

// MARK: LocalizedError
extension ACPError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .parseError(let detail):
      return "Parse error" + (detail.map { ": \($0)" } ?? "")
    case .invalidRequest(let detail):
      return "Invalid request" + (detail.map { ": \($0)" } ?? "")
    case .methodNotFound(let detail):
      return "Method not found" + (detail.map { ": \($0)" } ?? "")
    case .invalidParams(let detail):
      return "Invalid params" + (detail.map { ": \($0)" } ?? "")
    case .internalError(let detail):
      return "Internal error" + (detail.map { ": \($0)" } ?? "")
    case .authRequired(let detail):
      return "Authentication required" + (detail.map { ": \($0)" } ?? "")
    case .resourceNotFound(let detail):
      return "Resource not found" + (detail.map { ": \($0)" } ?? "")
    }
  }
}
