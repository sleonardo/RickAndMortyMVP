//
//  CharactersViewModel.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import RickMortySwiftApi
import SwiftUICore

@MainActor
class CharactersViewModel: ObservableObject {
    @Published var characters: [RMCharacterModel] = []
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    @Published var cacheStats: CacheStats = CacheStats(keys: [], size: 0)
    
    // Properties for search and filters
    @Published var searchText: String = ""
    @Published var filters = CharacterFilters()
    
    private let useCases: CharacterUseCases
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(characterRepository: CharacterRepositoryProtocol) {
        self.useCases = CharacterUseCases(repository: characterRepository)
    }
    
    // For previews with use cases
    init(useCases: CharacterUseCases) {
        self.useCases = useCases
    }
    
    // MARK: - Public Methods
    
    // Load initial characters
    func loadCharacters() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        showError = false
        
        do {
            let newCharacters = try await useCases.getCharacters(page: currentPage)
            
            if newCharacters.isEmpty {
                hasMorePages = false
            } else {
                characters.append(contentsOf: newCharacters)
                currentPage += 1
            }
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // Search characters by name
    func searchCharacters(with name: String) async {
        guard !name.isEmpty else {
            await resetSearch()
            return
        }
        
        searchTask?.cancel()
        
        searchTask = Task {
            isSearching = true
            isLoading = true
            showError = false
            
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            
            do {
                let searchResults = try await useCases.searchCharacters(
                    name: name,
                    status: filters.status,
                    gender: filters.gender
                )
                characters = searchResults
                hasMorePages = false
            } catch {
                if let useCaseError = error as? ErrorUseCase,
                   useCaseError == .notFound {
                    characters = []
                } else {
                    handleError(error)
                }
            }
            
            isLoading = false
        }
    }
    
    // Reset search and load initial characters
    func resetSearch() async {
        searchTask?.cancel()
        characters.removeAll()
        currentPage = 1
        hasMorePages = true
        isSearching = false
        searchText = ""
        filters = CharacterFilters()
        await loadCharacters()
    }
    
    // Refresh all data
    func refresh() async {
        characters.removeAll()
        currentPage = 1
        hasMorePages = true
        isSearching = false
        searchText = ""
        await loadCharacters()
    }
    
    // Load more characters for pagination
    func loadMoreCharactersIfNeeded(currentCharacter character: RMCharacterModel) async {
        guard !isSearching,
              !isLoading,
              hasMorePages,
              let lastCharacter = characters.last,
              character.id == lastCharacter.id else {
            return
        }
        
        await loadCharacters()
    }
    
    // Apply filters
    func applyFilters(status: Status?, gender: Gender?) {
        filters.status = status
        filters.gender = gender
        
        Task {
            if !searchText.isEmpty {
                await searchCharacters(with: searchText)
            } else {
                await refresh()
            }
        }
    }
    
    // MARK: - Cache Methods
    func loadCacheStats() async {
        do {
            let stats = try await useCases.getCacheStats()
            await MainActor.run {
                self.cacheStats = stats
            }
        } catch {
            print("Error loading cache stats: \(error)")
        }
    }
    
    func clearCache() async {
        do {
            try await useCases.clearCache()
            await loadCacheStats() // Refresh stats after clearing
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func handleError(_ error: Error) {
        showError = true
        
        if let errorUseCase = error as? ErrorUseCase {
            errorMessage = errorUseCase.localizedDescription
        } else if let repositoryError = error as? RepositoryError {
            errorMessage = repositoryError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        
        print("Error loading characters: \(error)")
    }
}

// MARK: - Cache Stats Model
struct CacheStats {
    let keys: [String]
    let size: Int64
    
    static let empty = CacheStats(keys: [], size: 0)
}

// MARK: - Character Filters
struct CharacterFilters {
    var status: Status?
    var gender: Gender?
}
