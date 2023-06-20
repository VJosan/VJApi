import Foundation

protocol NetworkProviderProtocol {
  func data(from url: URL, headers: [String: String]?) async throws -> Data
  func post(to url: URL, body: Data?, headers: [String: String]?) async throws -> Data
  func post(to url: URL, body: Data?, headers: [String: String]?) async throws
  func delete(at url: URL, body: Data?, headers: [String: String]?) async throws
  func put(at url: URL, body: Data?, headers: [String: String]?) async throws
}
