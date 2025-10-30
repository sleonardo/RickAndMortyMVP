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
                .rickAndMortyGradient()
                .navigationTitle(String(localized: "characters_list_navigation_title"))
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
                activeFiltersView
                
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
        Group {
            if viewModel.filters.hasActiveFilters {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(String(localized:"active_filters_text"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(String(localized:"clear_all_button")) {
                            print("🗑️ Clearing all filters")
                            viewModel.applyFilters(status: nil, gender: nil)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if let status = viewModel.filters.status {
                                FilterChip(
                                    text: String(localized: "status_text \(status.rawValue)"),
                                    onRemove: {
                                        print("🗑️ Removing status filter")
                                        viewModel.applyFilters(status: nil, gender: viewModel.filters.gender)
                                    }
                                )
                            }
                            
                            if let gender = viewModel.filters.gender {
                                FilterChip(
                                    text: String(localized: "gender_text \(gender.rawValue)"),
                                    onRemove: {
                                        print("🗑️ Removing gender filter")
                                        viewModel.applyFilters(status: viewModel.filters.status, gender: nil)
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
    
    private var hasActiveFilters: Bool {
        viewModel.filters.status != nil || viewModel.filters.gender != nil
    }
    
    private var loadingView: some View {
        ProgressView(String(localized:"loading_characters_label"))
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
                    },
                    viewModel: viewModel
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
                    String(localized:"no_results_title") : String(localized:"no_characters_title"),
                    message: viewModel.isSearching && !searchText.isEmpty ?
                        String(localized: "no_characters_found_for_message \(searchText)") :
                        String(localized:"check_your_connection_message"),
                    systemImage: viewModel.isSearching ? "person.slash" : "wifi.exclamationmark",
                    action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel(String(localized:"no_characters_available_label"))
                .accessibilityHint(String(localized:"pull_to_refresh_or_check_connection_label"))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.characters.enumerated()), id: \.element.uniqueID) { index, character in
                        characterRowView(character, index: index)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel(String(localized:"characters_list_label"))
                .accessibilityValue(String(localized: "\(viewModel.characters.count) characters"))
                .accessibilityHint(String(localized:"swipe_up_or_down_to_browse_characters_label"))
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
        .accessibilityLabel(String(localized: "character_info \(character.name)\(character.gender)\(character.status)"))
        .accessibilityHint(String(localized:"double_tap_to_view_details_label"))
        .accessibilityAddTraits(.isButton)
    }
    
    private var shouldShowSearchBar: Bool {
        !viewModel.characters.isEmpty || !searchText.isEmpty
    }
    
    private var loadingMoreView: some View {
        Group {
            if viewModel.isLoading && !viewModel.characters.isEmpty {
                ProgressView(String(localized: "loading_more_characters_label"))
                    .padding()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(String(localized: "loading_more_characters_label"))
                    .accessibilityHint(String(localized: "please_wait_more_characters_label"))
            } else if !viewModel.hasMorePages && !viewModel.characters.isEmpty {
                Text(String(localized: "you_have_reached_end_text"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(String(localized: "end_characters_list_label"))
                    .accessibilityHint(String(localized: "no_more_characters_to_load_label"))
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
