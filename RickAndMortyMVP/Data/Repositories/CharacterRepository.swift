//
//  CharacterRepository.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

// Data/Repositories/CharacterRepository.swift
import Foundation
import RickMortySwiftApi

class CharacterRepository: CharacterRepositoryProtocol {
    private let rmClient: RMClient
    private let cacheService: CacheServiceProtocol
    
    init(rmClient: RMClient = RMClient(), cacheService: CacheServiceProtocol) {
        self.rmClient = rmClient
        self.cacheService = cacheService
    }
    
    // MARK: - Character Operations
    func getAllCharacters() async throws -> [RMCharacterModel] {
        // Try cache first
        if let cachedCharacters = await cacheService.getCharacters() {
            print("📦 Loading \(cachedCharacters.count) characters from cache")
            return cachedCharacters
        }
        
        // Fetch from network
        print("🌐 Loading characters from network")
        let characters = try await rmClient.character().getAllCharacters()
        print("📥 Received \(characters.count) characters from network")
        // Cache the results
        await cacheService.setCharacters(characters)
        
        return characters
    }
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        let cacheKey = "characters_page_\(page)"
        
        // Try cache first
        if let cached: [RMCharacterModel] = await cacheService.get(key: cacheKey) {
            print("📦 Loading page \(page) from cache: \(cached.count) characters")
            return cached
        }
        
        // Fetch from network
        print("🌐 Loading page \(page) from network")
        let characters = try await rmClient.character().getCharactersByPageNumber(pageNumber: page)
        print("📥 Received page \(page): \(characters.count) characters")
        // Cache the results (shorter expiry for paginated data)
        await cacheService.set(characters, forKey: cacheKey, expiry: .hours(2))
        
        return characters
    }
    
    func getCharacter(id: Int) async throws -> RMCharacterModel {
        // Try cache first
        if let cachedCharacter = await cacheService.getCharacter(id: id) {
            print("📦 Loading character \(id) from cache")
            return cachedCharacter
        }
        
        // Fetch from network
        print("🌐 Loading character \(id) from network")
        let character = try await rmClient.character().getCharacterByID(id: id)
        
        // Cache the result
        await cacheService.setCharacter(character)
        
        return character
    }
    
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel] {
        // For search, we'll use cached all characters if available for better performance
        let allCharacters = try await getAllCharacters()
        
        return allCharacters.filter { character in
            let matchesName = name.isEmpty || character.name.localizedCaseInsensitiveContains(name)
            let matchesStatus = status == nil || character.status.lowercased() == status?.rawValue.lowercased()
            let matchesGender = gender == nil || character.gender.lowercased() == gender?.rawValue.lowercased()
            
            return matchesName && matchesStatus && matchesGender
        }
    }
    
    // MARK: - Cache Management
    func clearCache() async {
        await cacheService.clear()
    }
    
    func getCacheStats() async -> (keys: [String], size: Int64) {
        let keys = await cacheService.getKeys()
        let size = await cacheService.getSize()
        return (keys, size)
    }
}
