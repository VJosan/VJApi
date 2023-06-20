import Foundation

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var version: String { get }
    var queryParams: [String: String]? { get }
}

extension Endpoint {
  var scheme: String {
    return "https"
  }
}
