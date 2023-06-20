import Foundation

public class SCAPIError: Error, Decodable {
    var errorCode: Int?
    var childrenErrorCodes: [String]?
    var errorParameters: [String]?
}

public enum RequestError: Error {
    case invalidURL
    case unknown
  
    var customMessage: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .invalidURL:
            return "Invalid url"
        }
    }
}
