import Foundation

private let sharedEncoder = JSONEncoder()
private let sharedDecoder = JSONDecoder()

func decodeParams<T: Decodable>(_ params: AnyCodable?, as type: T.Type) throws -> T {
  let data = try sharedEncoder.encode(params)
  return try sharedDecoder.decode(T.self, from: data)
}
