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
    
    // MARK: - Private Properties
    private let rmClient: RMClient
    private var currentPage = 1
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    private var isSearching = false
    
    // MARK: - Initializer
    init(rmClient: RMClient = RMClient()) {
        self.rmClient = rmClient
        setupSearchDebouncing()
    }
    
    // MARK: - Public Methods
    func loadCharacters() async {
        guard !isLoading, !hasReachedEnd else { return }
        
        isLoading = true
        error = nil
        
        do {
            let dataCharacters: [RMCharacterModel]
            
            if isSearching || hasActiveFilters {
                // Use search with page 1 to simplify
                dataCharacters = try await loadAndFilterPage(page: currentPage)
            } else {
                // Paginated normal load
                dataCharacters = try await rmClient.character().getCharactersByPageNumber(pageNumber: currentPage)
            }
            
            if dataCharacters.isEmpty {
                hasReachedEnd = true
            } else {
                characters.append(contentsOf: dataCharacters)
                currentPage += 1
            }
        } catch {
            self.error = error.localizedDescription
            //await loadMockData()
        }
        
        isLoading = false
    }
    
    func searchCharacters() async {
        guard !searchText.isEmpty else {
            await resetToInitialState()
            return
        }
        
        isLoading = true
        error = nil
        characters.removeAll()
        currentPage = 1
        hasReachedEnd = false
        isSearching = true
        
        do {
            let results = try await loadAndFilterPage(page: currentPage)
            characters = results
            hasReachedEnd = true
        } catch {
            self.error = error.localizedDescription
            characters.removeAll()
        }
        
        isLoading = false
    }
    
    func applyFilters() async {
        isLoading = true
        error = nil
        characters.removeAll()
        currentPage = 1
        hasReachedEnd = false
        isSearching = true
        
        do {
            let results = try await loadAndFilterPage(page: currentPage)
            characters = results
            hasReachedEnd = true
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
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
        isSearching = false
        await resetToInitialState()
    }
    
    // MARK: - Computed Properties
    private var hasActiveFilters: Bool {
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
    
    private func loadMockData() async {
        // Fallback a data mock
        characters = CharacterMock.charactersMocks
    }
    
    // MARK: - Search and Filter Implementation
    private func loadAndFilterPage(page: Int) async throws -> [RMCharacterModel] {
        let pageCharacters = try await rmClient.character().getCharactersByPageNumber(pageNumber: page)
        return applyFiltersToCharacters(pageCharacters)
    }
    
    private func applyFiltersToCharacters(_ characters: [RMCharacterModel]) -> [RMCharacterModel] {
            return characters.filter { character in
                // Filter by name
                let matchesSearch = searchText.isEmpty ||
                    character.name.localizedCaseInsensitiveContains(searchText)
                
                // Filter by status
                let matchesStatus: Bool
                if let statusFilter = filters.status {
                    matchesStatus = character.status.lowercased() == statusFilter.rawValue.lowercased()
                } else {
                    matchesStatus = true
                }
                
                // Filter by species
                let matchesSpecies = filters.species.isEmpty ||
                    character.species.localizedCaseInsensitiveContains(filters.species)
                
                // Filter by gender
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
