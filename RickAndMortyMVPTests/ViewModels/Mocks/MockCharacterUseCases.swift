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
class MockCharacterUseCases: CharacterUseCasesProtocol {
    var charactersToReturn: [RMCharacterModel] = []
    var shouldThrowError = false
    var errorToThrow: Error = ErrorUseCase.networkError
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        if shouldThrowError {
            throw errorToThrow
        }
        return charactersToReturn
    }
    
    func getAllCharacters() async throws -> [RMCharacterModel] {
        if shouldThrowError {
            throw errorToThrow
        }
        return charactersToReturn
    }
    
    func getCharacter(id: Int) async throws -> RMCharacterModel {
        if shouldThrowError {
            throw errorToThrow
        }
        return CharacterMock.rickSanchezCharacter
    }
    
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        // Simulate filtering based on parameters
        var filteredCharacters = charactersToReturn
        
        if !name.isEmpty {
            filteredCharacters = filteredCharacters.filter { $0.name.localizedCaseInsensitiveContains(name) }
        }
        
        if let status = status {
            filteredCharacters = filteredCharacters.filter { $0.status.lowercased() == status.rawValue.lowercased() }
        }
        
        if let gender = gender {
            filteredCharacters = filteredCharacters.filter { $0.gender.lowercased() == gender.rawValue.lowercased() }
        }
        
        return filteredCharacters
    }
    
    func getCacheStats() async throws -> CacheStats {
        return CacheStats(keys: [], size: 0)
    }
    
    func clearCache() async throws {}
}
