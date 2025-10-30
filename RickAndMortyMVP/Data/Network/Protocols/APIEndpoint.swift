//
//  APIEndpoint.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 30/10/25.
//

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: String]? { get }
    var headers: [String: String]? { get }
}
