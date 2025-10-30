//
//  APIClientProtocol.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 30/10/25.
//

import Foundation

public protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        timeout: TimeInterval
    ) async throws -> T
}
