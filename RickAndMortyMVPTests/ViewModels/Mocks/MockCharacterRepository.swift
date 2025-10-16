//
//  MockCharacterRepository.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

// RickAndMortyTests/Mocks/MockCharacterRepository.swift
import Foundation
import RickMortySwiftApi
@testable import RickAndMortyMVP

class MockCharacterRepository: CharacterRepositoryProtocol {
    
    var mockCharacters: [RMCharacterModel]
    var shouldThrowError = false
    var delayNanoseconds: UInt64 = 0
    var cacheStatsToReturn: (keys: [String], size: Int64) = ([], 0)
    
    init(mockCharacters: [RMCharacterModel] = []) {
        self.mockCharacters = mockCharacters
    }
    
    func getAllCharacters() async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
        
        return mockCharacters
    }
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
        
        // Simulate pagination with page size of 2 for testing
        let pageSize = 2
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, mockCharacters.count)
        
        if startIndex >= mockCharacters.count {
            return []
        }
        
        return Array(mockCharacters[startIndex..<endIndex])
    }
    
    func getCharacter(id: Int) async throws -> RMCharacterModel {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Character not found"])
        }
        
        guard let character = mockCharacters.first(where: { $0.id == id }) else {
            throw NSError(domain: "TestError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Character not found"])
        }
        
        return character
    }
    
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        
        if shouldThrowError {
            throw NSError(domain: "TestError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Search failed"])
        }
        
        return mockCharacters.filter { character in
            let matchesName = name.isEmpty || character.name.localizedCaseInsensitiveContains(name)
            let matchesStatus = status == nil || character.status.lowercased() == status?.rawValue.lowercased()
            let matchesGender = gender == nil || character.gender.lowercased() == gender?.rawValue.lowercased()
            
            return matchesName && matchesStatus && matchesGender
        }
    }
    
    func clearCache() async {
        cacheStatsToReturn = ([], 0)
    }
    
    func getCacheStats() async -> (keys: [String], size: Int64) {
        return cacheStatsToReturn
    }
    
    // MARK: - Helper Methods
    
    private func simulateDelay() async throws {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
    }
    
    // MARK: - Test Configuration Methods
    
    func setMockCharacters(_ characters: [RMCharacterModel]) {
        self.mockCharacters = characters
    }
    
    func setShouldThrowError(_ shouldThrow: Bool) {
        self.shouldThrowError = shouldThrow
    }
    
    func setCacheStats(_ stats: (keys: [String], size: Int64)) {
        self.cacheStatsToReturn = stats
    }
}
