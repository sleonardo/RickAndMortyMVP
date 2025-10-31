//
//  CharacterRepository.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

class CharacterRepository: CharacterRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private let cacheService: CacheServiceProtocol
    
    init(apiClient: APIClientProtocol = APIClient.create(), cacheService: CacheServiceProtocol) {
        self.apiClient = apiClient
        self.cacheService = cacheService
    }
    
    // MARK: - Character Operations
    func getAllCharacters() async throws -> [RMCharacterModel] {
        // Try cache first
        if let cachedCharacters = await cacheService.getCharacters() {
            print("📦 Loading \(cachedCharacters.count) characters from cache")
            return cachedCharacters
        }
        
        // Fetch from network using our APIClient
        print("🌐 Loading characters from network")
        let endpoint = CharacterEndpoint.getCharacters(page: 1, filters: nil)
        let response: APIResponse<RMCharacterModel> = try await apiClient.request(endpoint)
        
        print("📥 Received \(response.results.count) characters from network")
        // Cache the results
        await cacheService.setCharacters(response.results)
        
        return response.results
    }
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        let cacheKey = StringKeys.CharacterRepository.charactersPage(page)
        
        // Try cache first
        if let cached: [RMCharacterModel] = await cacheService.get(key: cacheKey) {
            print("📦 Loading page \(page) from cache: \(cached.count) characters")
            return cached
        }
        
        // Fetch from network using our APIClient
        print("🌐 Loading page \(page) from network")
        let endpoint = CharacterEndpoint.getCharacters(page: page, filters: nil)
        let response: APIResponse<RMCharacterModel> = try await apiClient.request(endpoint)
        
        print("📥 Received page \(page): \(response.results.count) characters")
        // Cache the results
        await cacheService.set(response.results, forKey: cacheKey, expiry: .hours(2))
        
        return response.results
    }
    
    func getCharacter(id: Int) async throws -> RMCharacterModel {
        // Try cache first
        if let cachedCharacter = await cacheService.getCharacter(id: id) {
            print("📦 Loading character \(id) from cache")
            return cachedCharacter
        }
        
        // Fetch from network using our APIClient
        print("🌐 Loading character \(id) from network")
        let endpoint = CharacterEndpoint.getCharacter(id: id)
        let character: RMCharacterModel = try await apiClient.request(endpoint)
        
        // Cache the result
        await cacheService.setCharacter(character)
        
        return character
    }
    
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel] {
        // Build filters for API call
        var filters: [String: String] = [:]
        
        if !name.isEmpty {
            filters["name"] = name
        }
        
        if let status = status {
            filters["status"] = status.rawValue.lowercased()
        }
        
        if let gender = gender {
            filters["gender"] = gender.rawValue.lowercased()
        }
        
        // Use API search with our APIClient
        let endpoint = CharacterEndpoint.getCharacters(page: 1, filters: filters.isEmpty ? nil : filters)
        let response: APIResponse<RMCharacterModel> = try await apiClient.request(endpoint)
        
        print("🔍 Search found \(response.results.count) characters")
        return response.results
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
