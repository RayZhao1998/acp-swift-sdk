import Foundation

func decodeParams<T: Decodable>(_ params: AnyCodable?, as type: T.Type) throws -> T {
  let data = try JSONEncoder().encode(params)
  return try JSONDecoder().decode(T.self, from: data)
}
