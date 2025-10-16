//
//  CharacterUseCases.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

class CharacterUseCases {
    private let repository: CharacterRepositoryProtocol
    
    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Character Operations
    func getAllCharacters() async throws -> [RMCharacterModel] {
        try await repository.getAllCharacters()
    }
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        try await repository.getCharacters(page: page)
    }
    
    func getCharacter(id: Int) async throws -> [RMCharacterModel] {
        let character = try await repository.getCharacter(id: id)
        return [character]
    }
    
    func searchCharacters(name: String, filters: Filters) async throws -> [RMCharacterModel] {
        try await repository.searchCharacters(
            name: name,
            status: filters.status,
            gender: filters.gender
        )
    }
    
    // MARK: - Cache Management
    func clearCache() async {
        await repository.clearCache()
    }
    
    func getCacheStats() async -> (keys: [String], size: Int64) {
        await repository.getCacheStats()
    }
}
