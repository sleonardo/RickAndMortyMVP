//
//  CharacterUseCases.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

class CharacterUseCases: CharacterUseCasesProtocol {
    private let repository: CharacterRepositoryProtocol
    
    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        return try await repository.getCharacters(page: page)
    }
    
    func getAllCharacters() async throws -> [RMCharacterModel] {
        return try await repository.getAllCharacters()
    }
    
    func getCharacter(id: Int) async throws -> RMCharacterModel {
        return try await repository.getCharacter(id: id)
    }
    
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel] {
        return try await repository.searchCharacters(name: name, status: status, gender: gender)
    }
    
    func getCacheStats() async throws -> CacheStats {
        let stats = await repository.getCacheStats()
        return CacheStats(keys: stats.keys, size: stats.size)
    }
    
    func clearCache() async throws {
        await repository.clearCache()
    }
}
