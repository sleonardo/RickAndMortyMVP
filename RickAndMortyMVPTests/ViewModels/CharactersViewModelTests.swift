//
//  CharactersViewModelTests.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import XCTest
@testable import RickAndMortyMVP

@MainActor
final class CharactersViewModelTests: XCTestCase {
    
    var viewModel: CharactersViewModel!
    var mockUseCases: MockCharacterUseCases!
    
    override func setUp() {
        super.setUp()
        mockUseCases = MockCharacterUseCases()
        viewModel = CharactersViewModel(useCases: mockUseCases)
    }
    
    override func tearDown() {
        viewModel = nil
        mockUseCases = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.hasMorePages)
        XCTAssertEqual(viewModel.filters.status, nil)
        XCTAssertEqual(viewModel.filters.gender, nil)
    }
    
    // MARK: - Load Characters Tests
    
    func testLoadCharactersSuccess() async {
        // Given
        mockUseCases.charactersToReturn = CharacterMock.charactersMocks
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertFalse(viewModel.characters.isEmpty)
        XCTAssertEqual(viewModel.characters.count, 5)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoadCharactersEmpty() async {
        // Given
        mockUseCases.charactersToReturn = []
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.hasMorePages)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadCharactersError() async {
        // Given
        mockUseCases.shouldThrowError = true
        mockUseCases.errorToThrow = ErrorUseCase.networkError
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertTrue(viewModel.showError)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, ErrorUseCase.networkError.localizedDescription)
    }
    
    func testSearchCharactersEmptyQuery() async {
        // Given
        let initialCharacters = CharacterMock.charactersMocks
        mockUseCases.charactersToReturn = initialCharacters
        
        // When - Load some characters first
        await viewModel.loadCharacters()
        
        // Then - Search with empty query should reset
        await viewModel.searchCharacters(with: "")
        
        XCTAssertEqual(viewModel.characters.count, 5)
        XCTAssertFalse(viewModel.isSearching)
    }
    
    func testSearchCharactersNotFound() async {
        // Given
        let searchQuery = "NonExistentCharacter"
        mockUseCases.charactersToReturn = []
        
        // When
        await viewModel.searchCharacters(with: searchQuery)
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Filter Tests
    
    func testApplyStatusFilter() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.charactersToReturn = allCharacters
        
        // When
        viewModel.applyFilters(status: .alive, gender: nil)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.filters.status, .alive)
        XCTAssertNil(viewModel.filters.gender)
        
        // Verify only alive characters are shown
        let aliveCharacters = viewModel.characters.filter { $0.status.lowercased() == "alive" }
        XCTAssertEqual(viewModel.characters.count, aliveCharacters.count)
    }
    
    func testApplyGenderFilter() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.charactersToReturn = allCharacters
        
        // When
        viewModel.applyFilters(status: nil, gender: .male)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNil(viewModel.filters.status)
        XCTAssertEqual(viewModel.filters.gender, .male)
        
        // Verify only male characters are shown
        let maleCharacters = viewModel.characters.filter { $0.gender.lowercased() == "male" }
        XCTAssertEqual(viewModel.characters.count, maleCharacters.count)
    }
    
    func testApplyMultipleFilters() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.charactersToReturn = allCharacters
        
        // When
        viewModel.applyFilters(status: .alive, gender: .male)
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(viewModel.filters.status, .alive)
        XCTAssertEqual(viewModel.filters.gender, .male)
        
        // Verify only alive male characters are shown
        let filteredCharacters = viewModel.characters.filter {
            $0.status.lowercased() == "alive" && $0.gender.lowercased() == "male"
        }
        XCTAssertEqual(viewModel.characters.count, filteredCharacters.count)
    }
    
    func testClearFilters() async {
        // Given
        let allCharacters = CharacterMock.charactersMocks
        mockUseCases.charactersToReturn = allCharacters
        
        // Apply filters first
        viewModel.applyFilters(status: .alive, gender: .male)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Clear filters
        viewModel.applyFilters(status: nil, gender: nil)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertNil(viewModel.filters.status)
        XCTAssertNil(viewModel.filters.gender)
        XCTAssertEqual(viewModel.characters.count, 5) // All characters should be shown
    }
    
    func testFiltersWithSearch() async {
        // Given
        let searchQuery = "Smith"
        mockUseCases.charactersToReturn = [
            CharacterMock.mortySmithCharacter,
            CharacterMock.summerSmithCharacter,
            CharacterMock.bethSmithCharacter
        ]
        
        // Apply gender filter
        viewModel.applyFilters(status: nil, gender: .female)
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // When - Search with active filters
        await viewModel.searchCharacters(with: searchQuery)
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 2) // Only female Smith characters
        let femaleSmithCharacters = viewModel.characters.filter {
            $0.name.contains("Smith") && $0.gender.lowercased() == "female"
        }
        XCTAssertEqual(viewModel.characters.count, femaleSmithCharacters.count)
    }
    
    // MARK: - Pagination Tests
    
    func testLoadMoreCharacters() async {
        // Given
        let firstPageCharacters = Array(CharacterMock.charactersMocks.prefix(3))
        let secondPageCharacters = Array(CharacterMock.charactersMocks.suffix(2))
        
        mockUseCases.charactersToReturn = firstPageCharacters
        
        // Load first page
        await viewModel.loadCharacters()
        
        // Setup second page
        mockUseCases.charactersToReturn = secondPageCharacters
        
        // When - Load more
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertEqual(viewModel.characters.count, 5)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testLoadMoreCharactersWhenNoMorePages() async {
        // Given
        mockUseCases.charactersToReturn = []
        
        // When
        await viewModel.loadCharacters()
        
        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.hasMorePages)
    }
    
    func testRefresh() async {
        // Given
        mockUseCases.charactersToReturn = CharacterMock.charactersMocks
        await viewModel.loadCharacters()
        
        let initialCount = viewModel.characters.count
        
        // When
        await viewModel.refresh()
        
        // Then
        XCTAssertEqual(viewModel.characters.count, initialCount)
        XCTAssertFalse(viewModel.isLoading)
    }
}
