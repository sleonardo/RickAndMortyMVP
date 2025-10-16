//
//  PreviewCharacterViewModelFactory.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import Foundation
import RickMortySwiftApi

// MARK: - Preview ViewModel Factory
enum PreviewViewModelFactory {
    
    @MainActor
    static func createNormalState() -> CharactersViewModel {
        let repository = SuccessCharacterRepository()
        let useCases = CharacterUseCases(repository: repository)
        return CharactersViewModel(useCases: useCases)
    }
    
    @MainActor
    static func createEmptyState() -> CharactersViewModel {
        let repository = EmptyCharacterRepository()
        let useCases = CharacterUseCases(repository: repository)
        return CharactersViewModel(useCases: useCases)
    }
    
    @MainActor
    static func createLoadingState() -> CharactersViewModel {
        let repository = LoadingCharacterRepository()
        let useCases = CharacterUseCases(repository: repository)
        return CharactersViewModel(useCases: useCases)
    }
    
    @MainActor
    static func createErrorState() -> CharactersViewModel {
        let repository = ErrorCharacterRepository()
        let useCases = CharacterUseCases(repository: repository)
        return CharactersViewModel(useCases: useCases)
    }
    
    @MainActor
    static func createSearchState(searchText: String = "Rick") -> CharactersViewModel {
        let repository = SuccessCharacterRepository()
        let useCases = CharacterUseCases(repository: repository)
        let viewModel = CharactersViewModel(useCases: useCases)
        
        // Configure search status
        viewModel.searchText = searchText
        return viewModel
    }
    
    @MainActor
    static func createFilterState(status: Status? = .alive, gender: Gender? = .male) -> CharactersViewModel {
        let repository = SuccessCharacterRepository()
        let useCases = CharacterUseCases(repository: repository)
        let viewModel = CharactersViewModel(useCases: useCases)
        
        // Configure filters
        viewModel.filters.status = status
        viewModel.filters.gender = gender
        return viewModel
    }
}
