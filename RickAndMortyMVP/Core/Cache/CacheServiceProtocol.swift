//
//  CacheServiceProtocol.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

protocol CacheServiceProtocol {
    // MARK: - Basic Cache Operations
    func set<T: Codable>(_ value: T, forKey key: String, expiry: CacheExpiry) async
    func get<T: Codable>(key: String) async -> T?
    func remove(key: String) async
    func clear() async
    func clearExpired() async
    
    // MARK: - Advanced Operations
    func exists(key: String) async -> Bool
    func getKeys() async -> [String]
    func getSize() async -> Int64
    
    // MARK: - Specific Type Helpers
    func getCharacters() async -> [RMCharacterModel]?
    func setCharacters(_ characters: [RMCharacterModel]) async
    func getCharacter(id: Int) async -> RMCharacterModel?
    func setCharacter(_ character: RMCharacterModel) async
}

// MARK: - Cache Expiry
enum CacheExpiry {
    case never
    case seconds(TimeInterval)
    case minutes(Int)
    case hours(Int)
    case days(Int)
    case date(Date)
    
    var date: Date {
        switch self {
        case .never:
            return Date.distantFuture
        case .seconds(let seconds):
            return Date().addingTimeInterval(seconds)
        case .minutes(let minutes):
            return Date().addingTimeInterval(TimeInterval(minutes * 60))
        case .hours(let hours):
            return Date().addingTimeInterval(TimeInterval(hours * 3600))
        case .days(let days):
            return Date().addingTimeInterval(TimeInterval(days * 86400))
        case .date(let date):
            return date
        }
    }
}
