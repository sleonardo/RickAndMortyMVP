//
//  APIResponse.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 30/10/25.
//

public struct APIResponse<T: Codable>: Codable {
    public let info: APIInfo
    public let results: [T]
    
    public init(info: APIInfo, results: [T]) {
        self.info = info
        self.results = results
    }
}

public struct APIInfo: Codable {
    public let count: Int
    public let pages: Int
    public let next: String?
    public let prev: String?
    
    public init(count: Int, pages: Int, next: String?, prev: String?) {
        self.count = count
        self.pages = pages
        self.next = next
        self.prev = prev
    }
}
