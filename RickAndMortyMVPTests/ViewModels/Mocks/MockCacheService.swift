//
//  MockCacheService.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
@testable import RickAndMortyMVP
import RickMortySwiftApi

class MockCacheService: CacheServiceProtocol {
    var storage: [String: Any] = [:]
    var shouldThrowError = false
    
    func set<T: Codable>(_ value: T, forKey key: String, expiry: CacheExpiry) async {
        if shouldThrowError { return }
        storage[key] = value
    }
    
    func get<T: Codable>(key: String) async -> T? {
        if shouldThrowError { return nil }
        return storage[key] as? T
    }
    
    func remove(key: String) async {
        storage.removeValue(forKey: key)
    }
    
    func clear() async {
        storage.removeAll()
    }
    
    func clearExpired() async {
        // No-op para mock simple
    }
    
    func exists(key: String) async -> Bool {
        storage.keys.contains(key)
    }
    
    func getKeys() async -> [String] {
        Array(storage.keys)
    }
    
    func getSize() async -> Int64 {
        Int64(storage.count * 1024) // Simular 1KB por item
    }
    
    func getCharacters() async -> [RMCharacterModel]? {
        await get(key: "cached_characters")
    }
    
    func setCharacters(_ characters: [RMCharacterModel]) async {
        await set(characters, forKey: "cached_characters", expiry: .hours(6))
    }
    
    func getCharacter(id: Int) async -> RMCharacterModel? {
        await get(key: "character_\(id)")
    }
    
    func setCharacter(_ character: RMCharacterModel) async {
        await set(character, forKey: "character_\(character.id)", expiry: .days(1))
    }
}
