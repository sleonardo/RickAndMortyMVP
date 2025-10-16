//
//  MockCharacterUseCases.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
@testable import RickAndMortyMVP
import RickMortySwiftApi

@MainActor
class MockCharacterUseCases: CharacterUseCases {
    
    // Configurable properties for testing
    var mockCharacters: [RMCharacterModel] = []
    var shouldThrowError = false
    var pageSize = 20
    var cacheStats: (keys: [String], size: Int64) = ([], 0)
    var delayNanoseconds: UInt64 = 0
    
    // Inicializador simplificado que no depende de repository
    init(mockCharacters: [RMCharacterModel] = []) {
        // Crear el mock repository de forma síncrona
        let mockRepository = MockCharacterRepository(mockCharacters: mockCharacters)
        super.init(repository: mockRepository)
        self.mockCharacters = mockCharacters
    }
    
    // Métodos override que no dependen del repository real
    override func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
        
        // Simulate pagination
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, mockCharacters.count)
        
        if startIndex >= mockCharacters.count {
            return []
        }
        
        return Array(mockCharacters[startIndex..<endIndex])
    }
    
    override func getAllCharacters() async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
        
        return mockCharacters
    }
    
    override func getCharacter(id: Int) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Character not found"])
        }
        
        guard let character = mockCharacters.first(where: { $0.id == id }) else {
            throw NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Character not found"])
        }
        
        return [character]
    }
    
    override func searchCharacters(name: String, filters: Filters) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Search failed"])
        }
        
        let filtered = mockCharacters.filter { character in
            let matchesName = name.isEmpty || character.name.localizedCaseInsensitiveContains(name)
            let matchesStatus = filters.status == nil || character.status.lowercased() == filters.status?.rawValue.lowercased()
            let matchesSpecies = filters.species.isEmpty || character.species.localizedCaseInsensitiveContains(filters.species)
            let matchesGender = filters.gender == nil || character.gender.lowercased() == filters.gender?.rawValue.lowercased()
            
            return matchesName && matchesStatus && matchesSpecies && matchesGender
        }
        
        return filtered
    }
    
    override func clearCache() async {
        cacheStats = ([], 0)
    }
    
    override func getCacheStats() async -> (keys: [String], size: Int64) {
        return cacheStats
    }
    
    // MARK: - Private Methods
    
    private func simulateDelay() async throws {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
    }
}
