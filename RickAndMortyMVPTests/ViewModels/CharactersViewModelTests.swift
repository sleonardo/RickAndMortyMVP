//
//  CharactersViewModelTests.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import XCTest
import Combine
@testable import RickAndMortyMVP
import RickMortySwiftApi

@MainActor
final class CharactersViewModelTests: XCTestCase {
    
    private var viewModel: CharactersViewModel!
    private var mockUseCases: MockCharacterUseCases!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockUseCases = MockCharacterUseCases(mockCharacters: CharacterMock.charactersMocks)
        viewModel = CharactersViewModel(useCases: mockUseCases)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCases = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertFalse(viewModel.hasReachedEnd)
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertFalse(viewModel.isSearching)
    }
    
    // MARK: - Load Characters Tests
    
    func testLoadCharactersSuccess() async {
        // Given
        let expectedCharacters = CharacterMock.charactersMocks
        mockUseCases.mockCharacters = expectedCharacters
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.characters.count, expectedCharacters.count)
        XCTAssertEqual(viewModel.characters.first?.name, "Rick Sanchez")
    }
    
    func testLoadCharactersEmpty() async {
        // Given
        mockUseCases.mockCharacters = []
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasReachedEnd)
        XCTAssertTrue(viewModel.characters.isEmpty)
    }
    
    // MARK: - Pagination Tests
    
    func testPaginationLoadsMoreCharacters() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.mockCharacters = allCharacters
        mockUseCases.pageSize = 2
        
        // When - Load first page
        await viewModel.loadCharacters()
        
        // Then - First page loaded
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertFalse(viewModel.hasReachedEnd)
        
        // When - Load second page
        await viewModel.loadCharacters()
        
        // Then - Second page appended
        XCTAssertEqual(viewModel.characters.count, 4) // 2 + 2
    }
    
    func testPaginationStopsWhenNoMoreCharacters() async {
        // Given
        mockUseCases.mockCharacters = []
        mockUseCases.pageSize = 2
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertTrue(viewModel.hasReachedEnd)
        XCTAssertTrue(viewModel.characters.isEmpty)
    }
    
    // MARK: - Search Tests
    
    func testSearchCharactersSuccess() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.mockCharacters = allCharacters
        viewModel.searchText = "Rick"
        
        // When
        await viewModel.searchCharacters()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.name.contains("Rick") })
        XCTAssertTrue(viewModel.hasReachedEnd)
    }
    
    func testSearchCharactersEmptyResult() async {
        // Given
        mockUseCases.mockCharacters = CharacterMock.charactersMocks
        viewModel.searchText = "NonExistentCharacter"
        
        // When
        await viewModel.searchCharacters()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertTrue(viewModel.hasReachedEnd)
    }
    
    func testSearchCharactersClearsWhenEmpty() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.mockCharacters = allCharacters
        viewModel.searchText = "Rick"
        
        // When - Perform search
        await viewModel.searchCharacters()
        
        // Then - Has search results
        XCTAssertFalse(viewModel.characters.isEmpty)
        
        // When - Clear search
        viewModel.searchText = ""
        await viewModel.searchCharacters()
        
        // Then - Should load normal characters
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Filter Tests
    
    func testApplyFilters() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.mockCharacters = allCharacters
        viewModel.filters.status = .alive
        
        // When
        await viewModel.applyFilters()
        
        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.characters.allSatisfy { $0.status.lowercased() == "alive" })
        XCTAssertTrue(viewModel.hasReachedEnd)
    }
    
    func testClearSearchAndFilters() async {
        // Given
        viewModel.searchText = "Rick"
        viewModel.filters.status = .alive
        viewModel.filters.gender = .male
        
        // When
        await viewModel.clearSearchAndFilters()
        
        // Then
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertNil(viewModel.filters.status)
        XCTAssertNil(viewModel.filters.gender)
        XCTAssertTrue(viewModel.filters.species.isEmpty)
    }
    
    // MARK: - Cache Tests
    
    func testClearCache() async {
        // Given
        let initialStats = (keys: ["test1", "test2"], size: Int64(1024))
        mockUseCases.cacheStats = initialStats
        
        // When
        await viewModel.clearCache()
        
        // Then - Cache should be cleared
        XCTAssertTrue(viewModel.cacheStats.keys.isEmpty)
        XCTAssertEqual(viewModel.cacheStats.size, 0)
    }
    
    func testLoadCacheStats() async {
        // Given
        let expectedStats = (keys: ["character_1", "character_2"], size: Int64(2048))
        mockUseCases.cacheStats = expectedStats
        
        // When
        await viewModel.loadCacheStats()
        
        // Then
        XCTAssertEqual(viewModel.cacheStats.keys, expectedStats.keys)
        XCTAssertEqual(viewModel.cacheStats.size, expectedStats.size)
    }
    
    // MARK: - Computed Properties Tests
    
    func testHasActiveFilters() {
        // Test no filters
        XCTAssertFalse(viewModel.hasActiveFilters)
        
        // Test status filter
        viewModel.filters.status = .alive
        XCTAssertTrue(viewModel.hasActiveFilters)
        
        // Test gender filter
        viewModel.filters.status = nil
        viewModel.filters.gender = .male
        XCTAssertTrue(viewModel.hasActiveFilters)
        
        // Test species filter
        viewModel.filters.gender = nil
        viewModel.filters.species = "Human"
        XCTAssertTrue(viewModel.hasActiveFilters)
        
        // Test multiple filters
        viewModel.filters.status = .alive
        viewModel.filters.gender = .male
        viewModel.filters.species = "Human"
        XCTAssertTrue(viewModel.hasActiveFilters)
    }
}
