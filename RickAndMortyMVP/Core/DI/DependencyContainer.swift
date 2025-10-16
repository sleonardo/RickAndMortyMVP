//
//  DependencyContainer.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Services
    lazy var cacheService: CacheServiceProtocol = CacheService()
    lazy var rmClient: RMClient = RMClient()
    
    // MARK: - Repository
    lazy var characterRepository: CharacterRepositoryProtocol = CharacterRepository(
        rmClient: rmClient,
        cacheService: cacheService
    )
    
    // MARK: - Use Cases
    lazy var characterUseCases: CharacterUseCases = CharacterUseCases(
        repository: characterRepository
    )
    
    // MARK: - ViewModels
    @MainActor
    func makeCharactersViewModel() -> CharactersViewModel {
        CharactersViewModel(useCases: characterUseCases)
    }
}
