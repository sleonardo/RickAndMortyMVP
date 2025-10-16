//
//  CharactersListView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI

struct CharactersListView: View {
    @StateObject private var viewModel: CharactersViewModel
    @State private var searchText = ""
    @State private var showingCacheInfo = false
    
    // Initialization
    init(characterRepository: CharacterRepositoryProtocol) {
        _viewModel = StateObject(wrappedValue: CharactersViewModel(characterRepository: characterRepository))
    }
    
    // Initialization for testing/previews
    init(viewModel: CharactersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Search Bar
                        if !viewModel.characters.isEmpty || !searchText.isEmpty {
                            SearchBar(text: $searchText, onSearch: { query in
                                Task {
                                    await viewModel.searchCharacters(with: query)
                                }
                            })
                            .padding(.horizontal)
                        }
                        
                        // Characters List
                        ForEach(viewModel.characters, id: \.uniqueID) { character in
                            NavigationLink {
                                CharacterDetailView(character: character)
                            } label: {
                                CharacterRow(character: character)
                                    .padding(.horizontal)
                                    .onAppear {
                                        // Cargar más personajes cuando llegamos al final
                                        if character.id == viewModel.characters.last?.id &&
                                           !viewModel.isSearching &&
                                           !viewModel.isLoading &&
                                           viewModel.hasMorePages {
                                            Task {
                                                await viewModel.loadMoreCharactersIfNeeded(currentCharacter: character)
                                            }
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // Loading Footer
                        if viewModel.isLoading && !viewModel.characters.isEmpty {
                            ProgressView()
                                .scaleEffect(1.2)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        
                        // No more content indicator
                        if !viewModel.hasMorePages && !viewModel.characters.isEmpty {
                            Text("No more characters to load")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.immediately)
                
                // Empty state
                if viewModel.characters.isEmpty && !viewModel.isLoading {
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
                }
            }
            .navigationTitle("Characters")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingCacheInfo = true
                        } label: {
                            Label("Cache Info", systemImage: "internaldrive")
                        }
                        
                        Button {
                            Task {
                                await viewModel.refresh()
                            }
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        
                        // Button to clear cache directly
                        Button(role: .destructive) {
                            Task {
                                await viewModel.clearCache()
                                await viewModel.refresh()
                            }
                        } label: {
                            Label("Clear Cache", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingCacheInfo) {
            CacheInfoView(viewModel: viewModel)
        }
        .errorBanner(
            isPresented: $viewModel.showError,
            error: viewModel.errorMessage,
            errorType: determineErrorType(),
            onRetry: {
                Task {
                    await viewModel.refresh()
                }
            }
        )
        .task {
            // Load initial characters when the view appears
            if viewModel.characters.isEmpty {
                await viewModel.loadCharacters()
            }
        }
        .onChange(of: searchText) { oldValue, newValue in
            // Handling changes in the search text
            if newValue.isEmpty {
                Task {
                    await viewModel.resetSearch()
                }
            }
        }
        .overlay {
            // Loading overlay for initial loading
            if viewModel.isLoading && viewModel.characters.isEmpty {
                ProgressView("Loading characters...")
                    .scaleEffect(1.2)
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(12)
            }
        }
    }
    
    // Determine the error type for the banner
    private func determineErrorType() -> ErrorBanner.ErrorType {
        guard let errorMessage = viewModel.errorMessage else { return .general }
        
        if errorMessage.lowercased().contains("network") ||
           errorMessage.lowercased().contains("connection") ||
           errorMessage.lowercased().contains("internet") {
            return .network
        } else if errorMessage.lowercased().contains("server") {
            return .server
        } else {
            return .general
        }
    }
}

// MARK: - Previews
#Preview("Normal State") {
    CharactersListView(viewModel: PreviewViewModelFactory.createNormalState())
}

#Preview("Empty State") {
    CharactersListView(viewModel: PreviewViewModelFactory.createEmptyState())
}

#Preview("Loading State") {
    CharactersListView(viewModel: PreviewViewModelFactory.createLoadingState())
}

#Preview("Error State") {
    CharactersListView(viewModel: PreviewViewModelFactory.createErrorState())
}

#Preview("Search State") {
    CharactersListView(viewModel: PreviewViewModelFactory.createSearchState())
}

#Preview("With Cache") {
    CharactersListView(viewModel: PreviewViewModelFactory.createWithCache())
}
