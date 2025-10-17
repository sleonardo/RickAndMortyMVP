//
//  CharacterUseCasesProtocol.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import Foundation
import RickMortySwiftApi

protocol CharacterUseCasesProtocol {
    // MARK: - Character Operations
    func getCharacters(page: Int) async throws -> [RMCharacterModel]
    func getAllCharacters() async throws -> [RMCharacterModel]
    func getCharacter(id: Int) async throws -> RMCharacterModel
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel]
    
    // MARK: - Cache Management
    func getCacheStats() async throws -> CacheStats
    func clearCache() async throws
}
