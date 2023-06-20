import Foundation
#if os(iOS)
class Api: ApiProtocol {
    required init(networkProvider: NetworkProviderProtocol) {
        self.networkProvider = networkProvider
    }
    
    private let networkProvider: NetworkProviderProtocol
    var headers: [String: String] = [:]
    
    func get<T: Decodable>(endpoint: Endpoint, headers: [String: String]?) async throws -> T {
        let url = try url(from: endpoint)
        let data = try await networkProvider.data(from: url, headers: headers)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.customISO8601
        let model = try decoder.decode(T.self, from: data)
        return model
    }

    func delete(endpoint: Endpoint, headers: [String: String]?) async throws {
        let url = try url(from: endpoint)
        try await networkProvider.delete(at: url, body: nil, headers: headers)
    }
    
    func delete(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws {
        let url = try url(from: endpoint)
        let bodyData = try dataWithJsonEncoding(from: model)
        try await networkProvider.delete(at: url, body: bodyData, headers: headers)
    }
    
    func post<T: Decodable>(endpoint: Endpoint, data: Data?, headers: [String: String]?) async throws -> T {
        return try await postData(endpoint: endpoint, data: data, headers: headers)
    }
    
    func post<T: Decodable>(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws -> T {
        let bodyData = try dataWithJsonEncoding(from: model)
        return try await postData(endpoint: endpoint, data: bodyData, headers: headers)
    }
    
    func post(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws {
        let bodyData = try dataWithJsonEncoding(from: model)
        let url = try url(from: endpoint)
        return try await networkProvider.post(to: url, body: bodyData, headers: headers)
    }
    
    func postURLEncoder<T: Decodable>(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws -> T {
        let bodyData = try dataWithUrlUncodedForm(from: model)
        return try await postData(endpoint: endpoint, data: bodyData, headers: headers)
    }
    
    func put(endpoint: Endpoint, model: Encodable, headers: [String: String]?) async throws {
        let url = try url(from: endpoint)
        let bodyData = try dataWithJsonEncoding(from: model)
        return try await networkProvider.put(at: url, body: bodyData, headers: headers)
    }
    
    private func url(from endpoint: Endpoint) throws -> URL {
        var urlCompontents = URLComponents()
        urlCompontents.scheme = endpoint.scheme
        
        if endpoint.host.contains("/") {
            let host = endpoint.host.components(separatedBy: "/")
            urlCompontents.host = host[0]
            urlCompontents.path = "/" + host[1] + endpoint.version + endpoint.path
        } else {
            urlCompontents.host = endpoint.host
            urlCompontents.path = endpoint.version + endpoint.path
        }
        
        
        
        if let queryParams = endpoint.queryParams  {
            for queryParam in queryParams {
                if urlCompontents.queryItems == nil {
                    urlCompontents.queryItems = []
                }
                urlCompontents.queryItems?.append(URLQueryItem(name: queryParam.key, value: queryParam.value))
            }
        }
        if let url = urlCompontents.url {
            return url
        } else {
            throw RequestError.invalidURL
        }
    }
    
    
    private func dataWithJsonEncoding(from model: Encodable) throws -> Data {
        return try JSONEncoder().encode(model)
    }
    
    private func dataWithUrlUncodedForm(from model: Encodable) throws -> Data {
        return try URLEncodedFormEncoder().encode(model)
    }
    
    private func postData<T: Decodable>(endpoint: Endpoint, data: Data?, headers: [String: String]?) async throws -> T {
        let url = try url(from: endpoint)
        let data: Data = try await networkProvider.post(to: url, body: data, headers: headers)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.customISO8601
        let model = try decoder.decode(T.self, from: data)
        return model
    }
}

extension URLSession: NetworkProviderProtocol {
    func data(from url: URL, headers: [String: String]?) async throws -> Data {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let urlResponse = urlResponse as? HTTPURLResponse {
            switch urlResponse.statusCode {
                case 200...299:
                    return data
                default:
                    let decoder = JSONDecoder()
                    let scApiError = try decoder.decode(SCAPIError.self, from: data)
                    throw scApiError
            }
        } else {
            throw RequestError.unknown
        }
    }
    
    
    func delete(at url: URL, body: Data?, headers: [String: String]?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let urlResponse = urlResponse as? HTTPURLResponse {
            switch urlResponse.statusCode {
                case 200...299:
                    return
                default:
                    let decoder = JSONDecoder()
                    let scApiError = try decoder.decode(SCAPIError.self, from: data)
                    throw scApiError
            }
        } else {
            throw RequestError.unknown
        }
    }
    
    func post(to url: URL, body: Data?, headers: [String: String]?) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let urlResponse = urlResponse as? HTTPURLResponse {
            switch urlResponse.statusCode {
                case 200...299:
                    return data
                default:
                    let decoder = JSONDecoder()
                    let scApiError = try decoder.decode(SCAPIError.self, from: data)
                    throw scApiError
            }
        } else {
            throw RequestError.unknown
        }
    }
    
    func post(to url: URL, body: Data?, headers: [String: String]?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let urlResponse = urlResponse as? HTTPURLResponse {
            switch urlResponse.statusCode {
                case 200...299:
                    return
                default:
                    let decoder = JSONDecoder()
                    let scApiError = try decoder.decode(SCAPIError.self, from: data)
                    throw scApiError
            }
        } else {
            throw RequestError.unknown
        }
    }
    
    func put(at url: URL, body: Data?, headers: [String: String]?) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = body
        request.allHTTPHeaderFields = headers
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        if let urlResponse = urlResponse as? HTTPURLResponse {
            switch urlResponse.statusCode {
                case 200...299:
                    return
                default:
                    let decoder = JSONDecoder()
                    let scApiError = try decoder.decode(SCAPIError.self, from: data)
                    throw scApiError
            }
        } else {
            throw RequestError.unknown
        }
    }
}

#else
#endif
