//
//  CharacterRepositoryProtocol.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

protocol CharacterRepositoryProtocol {
    // MARK: - Character Operations
    func getAllCharacters() async throws -> [RMCharacterModel]
    func getCharacters(page: Int) async throws -> [RMCharacterModel]
    func getCharacter(id: Int) async throws -> RMCharacterModel
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel]
    
    // MARK: - Cache Management
    func clearCache() async
    func getCacheStats() async -> (keys: [String], size: Int64)
}
