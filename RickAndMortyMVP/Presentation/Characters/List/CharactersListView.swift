//
//  CharactersListView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharactersListView: View {
    @StateObject private var viewModel: CharactersViewModel
    @State private var searchText = ""
    @State private var showingCacheInfo = false
    @State private var showingFilters = false
    
    // Initialization
    init(characterRepository: CharacterRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: CharactersViewModel(characterRepository: characterRepository))
    }
    
    // Initialization for testing/previews
    init(viewModel: CharactersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Rick & Morty")
                .toolbar { toolbarContent }
                .sheet(isPresented: $showingCacheInfo) {
                    CacheInfoView(viewModel: viewModel)
                }
                .sheet(isPresented: $showingFilters) {
                    FiltersView(viewModel: viewModel)
                }
                .task {
                    await viewModel.loadCharacters()
                }
        }
    }
    
    // MARK: - Main Content Views
    
    private var contentView: some View {
        ZStack {
            backgroundGradient
            Group {
                if viewModel.isLoading && viewModel.characters.isEmpty {
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    errorView(errorMessage)
                } else {
                    scrollContentView
                }
            }
        }
    }
    
    private var scrollContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Show active filters if they exist
                if hasActiveFilters {
                    activeFiltersView
                }
                
                searchBarView
                charactersContentView
                loadingMoreView
            }
            .padding(.vertical, 8)
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    // View to show active filters
    private var activeFiltersView: some View {
        HStack {
            Text("Active Filters:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let status = viewModel.filters.status {
                FilterChip(text: "Status: \(status.rawValue)",
                          onRemove: { viewModel.applyFilters(status: nil, gender: viewModel.filters.gender) })
            }
            
            if let gender = viewModel.filters.gender {
                FilterChip(text: "Gender: \(gender.rawValue)",
                          onRemove: { viewModel.applyFilters(status: viewModel.filters.status, gender: nil) })
            }
            
            Spacer()
            
            Button("Clear All") {
                viewModel.applyFilters(status: nil, gender: nil)
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.horizontal)
    }
    
    private var hasActiveFilters: Bool {
        viewModel.filters.status != nil || viewModel.filters.gender != nil
    }
    
    private var loadingView: some View {
        ProgressView("Loading characters...")
            .foregroundStyle(.white)
    }
    
    private func errorView(_ message: String) -> some View {
        ErrorBannerView(
            message: message,
            onRetry: {
                Task {
                    await viewModel.loadCharacters()
                }
            }
        )
    }
    
    private var searchBarView: some View {
        Group {
            if shouldShowSearchBar {
                SearchBar(
                    text: $searchText,
                    onSearch: { query in
                        Task {
                            await viewModel.searchCharacters(with: query)
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    private var charactersContentView: some View {
        Group {
            if viewModel.characters.isEmpty {
                EmptyStateView(
                    title: viewModel.isSearching && !searchText.isEmpty ?
                        "No Results" : "No Characters",
                    message: viewModel.isSearching && !searchText.isEmpty ?
                        "No characters found for \"\(searchText)\"" :
                        "Unable to load characters. Please check your connection and try again.",
                    systemImage: viewModel.isSearching ? "person.slash" : "wifi.exclamationmark",
                    action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("No characters available")
                .accessibilityHint("Pull to refresh or check your internet connection")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.characters.enumerated()), id: \.element.uniqueID) { index, character in
                        characterRowView(character, index: index)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Characters list")
                .accessibilityValue("\(viewModel.characters.count) characters")
                .accessibilityHint("Swipe up or down to browse characters")
            }
        }
    }
    
    private func characterRowView(_ character: RMCharacterModel, index: Int) -> some View {
        NavigationLink {
            CharacterDetailView(character: character)
        } label: {
            CharacterRow(character: character)
                .padding(.horizontal, 16)
                .onAppear {
                    Task {
                        await viewModel.loadMoreCharactersIfNeeded(currentCharacter: character)
                    }
                }
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Name: \(character.name), Gender: \(character.gender), Status: \(character.status)")
        .accessibilityHint("Double tap to view details")
        .accessibilityAddTraits(.isButton)
    }
    
    private var shouldShowSearchBar: Bool {
        !viewModel.characters.isEmpty || !searchText.isEmpty
    }
    
    private var loadingMoreView: some View {
        Group {
            if viewModel.isLoading && !viewModel.characters.isEmpty {
                ProgressView("Loading more characters...")
                    .padding()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Loading more characters")
                    .accessibilityHint("Please wait while more characters are loading")
            } else if !viewModel.hasMorePages && !viewModel.characters.isEmpty {
                Text("You've reached the end")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("End of characters list")
                    .accessibilityHint("No more characters to load")
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    // Filter button
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                    
                    // Cache info button
                    Button {
                        showingCacheInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Success State") {
    CharactersListView(
        viewModel: CharactersViewModel(
            useCases: CharacterUseCases(repository: MockCharacterRepository(previewData: .success))
        )
    )
}

#Preview("Empty State") {
    CharactersListView(
        viewModel: CharactersViewModel(
            useCases: CharacterUseCases(repository: MockCharacterRepository(previewData: .empty))
        )
    )
}

#Preview("Loading State") {
    CharactersListView(
        viewModel: CharactersViewModel(
            useCases: CharacterUseCases(repository: MockCharacterRepository(previewData: .loading))
        )
    )
}

#Preview("Error State") {
    CharactersListView(
        viewModel: CharactersViewModel(
            useCases: CharacterUseCases(repository: MockCharacterRepository(previewData: .error))
        )
    )
}

#Preview("CharacterRow - Rick Sanchez", traits: .sizeThatFitsLayout) {
    CharacterRow(
        character: CharacterMock.rickSanchezCharacter
    )
    .padding()
    .background(Color.black.opacity(0.1))
}

#Preview("CharacterRow - Morty Smith", traits: .sizeThatFitsLayout) {
    CharacterRow(
        character: CharacterMock.mortySmithCharacter
    )
    .padding()
    .background(Color.black.opacity(0.1))
}

#Preview("Filter Chip", traits: .sizeThatFitsLayout) {
    VStack {
        FilterChip(text: "Status: Alive", onRemove: {})
        FilterChip(text: "Gender: Male", onRemove: {})
        FilterChip(text: "Species: Human", onRemove: {})
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Filters View") {
    FiltersView(
        viewModel: CharactersViewModel(
            useCases: CharacterUseCases(repository: MockCharacterRepository(previewData: .success))
        )
    )
}

#Preview("Fixed Size", traits: .fixedLayout(width: 300, height: 200)) {
    CharacterRow(character: CharacterMock.rickSanchezCharacter)
}
