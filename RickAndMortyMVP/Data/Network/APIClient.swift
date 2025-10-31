//
//  APIClient.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 30/10/25.
//

import Foundation

public final class APIClient: APIClientProtocol {
    private let baseURL: String
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let isLoggingEnabled: Bool
    
    // Inicializador interno
    private init(
        baseURL: String,
        urlSession: URLSession,
        jsonDecoder: JSONDecoder,
        isLoggingEnabled: Bool
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
        self.isLoggingEnabled = isLoggingEnabled
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public static func create(
        baseURL: String? = nil,
        urlSession: URLSession = .shared,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        isLoggingEnabled: Bool? = nil
    ) -> APIClient {
        return APIClient(
            baseURL: baseURL ?? AppEnvironment.apiBaseURL,
            urlSession: urlSession,
            jsonDecoder: jsonDecoder,
            isLoggingEnabled: isLoggingEnabled ?? AppEnvironment.isLoggingEnabled
        )
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await request(endpoint, timeout: 30.0)
    }
    
    public func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        timeout: TimeInterval = 30.0
    ) async throws -> T {
        let urlRequest = try buildURLRequest(for: endpoint, timeout: timeout)
        
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.from(statusCode: httpResponse.statusCode)
            }
            
            do {
                return try jsonDecoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
            
        } catch let error as APIError {
            throw error
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw APIError.timeout
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    private func buildURLRequest(
        for endpoint: APIEndpoint,
        timeout: TimeInterval
    ) throws -> URLRequest {
        let urlString = baseURL + endpoint.path
        
        guard var urlComponents = URLComponents(string: urlString) else {
            throw APIError.invalidURL
        }
        
        // Add query parameters if they exist
        if let parameters = endpoint.parameters {
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.timeoutInterval = timeout
        
        // Default headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Endpoint-specific headers
        if let headers = endpoint.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return urlRequest
    }
}
