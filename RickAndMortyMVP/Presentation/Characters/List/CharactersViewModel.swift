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
    @Published var filters = CharacterFilters() {
        didSet {
            print("🔄 Filters updated - Status: \(filters.status?.rawValue ?? "None"), Gender: \(filters.gender?.rawValue ?? "None")")
        }
    }
    
    private let useCases: CharacterUseCasesProtocol
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(characterRepository: CharacterRepositoryProtocol) {
        self.useCases = CharacterUseCases(repository: characterRepository)
    }
    
    // For previews with use cases
    init(useCases: CharacterUseCasesProtocol) {
        self.useCases = useCases
    }
    
    // MARK: - Public Methods
    
    // Load initial characters
    func loadCharacters() async {
        guard !isLoading, hasMorePages else { return }
        
        isLoading = true
        showError = false
        
        do {
            let newCharacters: [RMCharacterModel]
            
            // When filters are active, use search with filters
            if filters.status != nil || filters.gender != nil {
                // For filters without search text, load all and filter
                let allCharacters = try await useCases.getAllCharacters()
                newCharacters = allCharacters.filter { character in
                    let matchesStatus = filters.status == nil ||
                        character.status.lowercased() == filters.status?.rawValue.lowercased()
                    let matchesGender = filters.gender == nil ||
                        character.gender.lowercased() == filters.gender?.rawValue.lowercased()
                    
                    return matchesStatus && matchesGender
                }
                hasMorePages = false // Filters are not paginatedClick to apply
            } else {
                // Normal paginated load
                newCharacters = try await useCases.getCharacters(page: currentPage)
                hasMorePages = !newCharacters.isEmpty
            }
            
            if newCharacters.isEmpty {
                hasMorePages = false
            } else {
                characters.append(contentsOf: newCharacters)
                if filters.status == nil && filters.gender == nil {
                    currentPage += 1
                }
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
                print("🔍 Searching for: '\(name)' with filters - Status: \(filters.status?.rawValue ?? "None"), Gender: \(filters.gender?.rawValue ?? "None")")
                
                let searchResults = try await useCases.searchCharacters(
                    name: name,
                    status: filters.status,
                    gender: filters.gender
                )
                
                await MainActor.run {
                    print("✅ Search results: \(searchResults.count) characters")
                    self.characters = searchResults
                    self.hasMorePages = false
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("❌ Search error: \(error)")
                    if let useCaseError = error as? ErrorUseCase,
                       useCaseError == .notFound {
                        self.characters = []
                    } else {
                        self.handleError(error)
                    }
                    self.isLoading = false
                }
            }
        }
    }
    
    // Reset search and load initial characters
    func resetSearch() async {
        print("🔄 Resetting search")
        searchTask?.cancel()
        characters.removeAll()
        currentPage = 1
        hasMorePages = true
        isSearching = false
        searchText = ""
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
        print("🎯 Applying filters - Status: \(status?.rawValue ?? "None"), Gender: \(gender?.rawValue ?? "None")")
        
        filters.status = status
        filters.gender = gender
        
        Task {
            if !searchText.isEmpty {
                // Check if there is any search text, then search again with the new filters.
                print("🔄 Re-searching with new filters")
                await searchCharacters(with: searchText)
            } else {
                // Otherwise, load normally with filters
                await refreshWithFilters()
            }
        }
    }
    
    private func refreshWithFilters() async {
        print("🔄 Refreshing with filters - Status: \(filters.status?.rawValue ?? "None"), Gender: \(filters.gender?.rawValue ?? "None")")
        characters.removeAll()
        currentPage = 1
        hasMorePages = true
        isSearching = false
        searchText = ""
        
        await loadCharacters()
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
