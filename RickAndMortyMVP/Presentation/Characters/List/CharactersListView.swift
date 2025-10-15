//
//  CharactersListView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharactersListView: View {
    // MARK: - State Properties
    @StateObject private var viewModel = CharactersViewModel()
    @State private var showingFilters = false
    
    // Previews - Allow data injection
    internal var previewCharacters: [RMCharacterModel]?
    
    var displayCharacters: [RMCharacterModel] {
        previewCharacters ?? viewModel.characters
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.characters.isEmpty {
                    loadingView
                } else if viewModel.characters.isEmpty {
                    emptyStateView
                } else {
                    characterList
                }
            }
            .navigationTitle("Rick & Morty")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search characters...")
            .sheet(isPresented: $showingFilters) {
                FilterView(filters: $viewModel.filters)
            }
            .task {
                if viewModel.characters.isEmpty {
                    await viewModel.loadCharacters()
                }
            }
        }
    }
    
    private var characterList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(displayCharacters) { character in
                    NavigationLink {
                        CharacterDetailView(character: character)
                    } label: {
                        CharacterRow(character: character)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
        
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No characters found")
                .font(.title2)
                .foregroundColor(.gray)
            
            if !viewModel.searchText.isEmpty || viewModel.filters.status != nil || viewModel.filters.gender != nil || !viewModel.filters.species.isEmpty {
                Button("Clear Search & Filters") {
                    Task {
                        await viewModel.clearSearchAndFilters()
                    }
                }
                .buttonStyle(.bordered)
            } else {
                Button("Retry") {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
    }
        
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            Text("Loading characters...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolRenderingMode(.multicolor)
        }
    }
}

// MARK: - Previews by status
#Preview("Content State") {
    CharactersListView(previewCharacters: CharacterMock.charactersMocks)
}

#Preview("Empty State") {
    CharactersListView(previewCharacters: CharacterMock.emptyMocks)
}

#Preview("Loading State") {
    CharactersListView()
        .onAppear {
            // Keep loading status
        }
}
