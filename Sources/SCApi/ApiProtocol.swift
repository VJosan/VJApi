import Foundation

protocol ApiProtocol {
  init(networkProvider: NetworkProviderProtocol)
  func get<T: Decodable>(endpoint: Endpoint, headers: [String: String]?) async throws -> T
  func post(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws
  func post<T: Decodable>(endpoint: Endpoint, data: Data?, headers: [String: String]?) async throws -> T
  func post<T: Decodable>(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws -> T
  func postURLEncoder<T: Decodable>(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws -> T
  func delete(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws
  func delete(endpoint: Endpoint, headers: [String: String]?) async throws
  func put(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws
}
