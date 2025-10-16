//
//  CharactersViewModel.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi
import Combine

@MainActor
class CharactersViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var characters: [RMCharacterModel] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var searchText = ""
    @Published var filters = Filters()
    @Published var hasReachedEnd = false
    @Published var cacheStats: (keys: [String], size: Int64) = ([], 0)

    // MARK: - Public Properties
    var isSearching = false
    
    // MARK: - Private Properties
    private let useCases: CharacterUseCases
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(useCases: CharacterUseCases) {
        self.useCases = useCases
        setupSearchDebouncing()
    }
        
    // MARK: - Public Methods
    func onAppear() async {
        await loadCacheStats()
    }
    
    func loadCharacters() async {
        guard !isLoading, !hasReachedEnd else { return }
        
        isLoading = true
        error = nil
        
        do {
            let dataCharacters: [RMCharacterModel]
            
            if isSearching || hasActiveFilters {
                // Use search with page 1 to simplify
                dataCharacters = try await useCases.getAllCharacters()
                let filteredCharacters = applyFiltersToCharacters(dataCharacters)
                characters = filteredCharacters
                hasReachedEnd = true
            } else {
                // Paginated normal load
                dataCharacters = try await useCases.getCharacters(page: currentPage)
                
                if dataCharacters.isEmpty {
                    hasReachedEnd = true
                } else {
                    characters.append(contentsOf: dataCharacters)
                    currentPage += 1
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
        await loadCacheStats()
    }
    
    func searchCharacters() async {
        guard !searchText.isEmpty else {
            await resetToInitialState()
            return
        }
        
        isLoading = true
        error = nil
        isSearching = true
        
        do {
            let results = try await useCases.searchCharacters(name: searchText, filters: filters)
            characters = results
            hasReachedEnd = true
        } catch {
            self.error = error.localizedDescription
            characters.removeAll()
        }
        
        isLoading = false
        await loadCacheStats()
    }
    
    func applyFilters() async {
        isLoading = true
        error = nil
        isSearching = true
        
        do {
            let allCharacters = try await useCases.getAllCharacters()
            let results = applyFiltersToCharacters(allCharacters)
            characters = results
            hasReachedEnd = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
        await loadCacheStats()
    }
    
    func refresh() async {
        characters.removeAll()
        currentPage = 1
        hasReachedEnd = false
        isSearching = false
        await loadCharacters()
    }
    
    func clearSearchAndFilters() async {
        searchText = ""
        filters = Filters()
        await resetToNormalState()
    }
    
    // MARK: - Cache Management
    func clearCache() async {
        await useCases.clearCache()
        await loadCacheStats()
        await refresh() // Reload data
    }
    
    // MARK: - Computed Properties
    var hasActiveFilters: Bool {
        filters.status != nil || filters.gender != nil || !filters.species.isEmpty
    }
    
    // MARK: - Private Methods
    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.performSearch()
            }
            .store(in: &cancellables)
        
        // Respond to changes in filters
        $filters
            .dropFirst() // Ignore initial value
            .sink { [weak self] _ in
                self?.performFilter()
            }
            .store(in: &cancellables)
    }
    
    private func performSearch() {
        searchTask?.cancel()
        searchTask = Task {
            if searchText.isEmpty && !hasActiveFilters {
                await resetToInitialState()
            } else if !searchText.isEmpty {
                await searchCharacters()
            }
        }
    }
    
    private func performFilter() {
        Task {
            if hasActiveFilters {
                await applyFilters()
            } else if searchText.isEmpty {
                await resetToInitialState()
            }
        }
    }
    
    private func resetToInitialState() async {
        characters.removeAll()
        currentPage = 1
        hasReachedEnd = false
        isSearching = false
        await loadCharacters()
    }
    
    private func resetToNormalState() async {
        isSearching = false
        characters.removeAll()
        currentPage = 1
        hasReachedEnd = false
        await loadCharacters()
    }
    
    private func loadMockData() async {
        characters = CharacterMock.charactersMocks
    }
    
    func loadCacheStats() async {
        cacheStats = await useCases.getCacheStats()
    }
    
    private func applyFiltersToCharacters(_ characters: [RMCharacterModel]) -> [RMCharacterModel] {
        return characters.filter { character in
            let matchesSearch = searchText.isEmpty ||
                character.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus: Bool
            if let statusFilter = filters.status {
                matchesStatus = character.status.lowercased() == statusFilter.rawValue.lowercased()
            } else {
                matchesStatus = true
            }
            
            let matchesSpecies = filters.species.isEmpty ||
                character.species.localizedCaseInsensitiveContains(filters.species)
            
            let matchesGender: Bool
            if let genderFilter = filters.gender {
                matchesGender = character.gender.lowercased() == genderFilter.rawValue.lowercased()
            } else {
                matchesGender = true
            }
            
            return matchesSearch && matchesStatus && matchesSpecies && matchesGender
        }
    }
}
