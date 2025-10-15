//
//  CharactersListView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharactersListView: View {
    @State private var characters: [RMCharacterModel] = []
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var filters = Filters()
    @State private var isLoading = false
    
    // Previews - Allow data injection
    internal var previewCharacters: [RMCharacterModel]?
    
    var displayCharacters: [RMCharacterModel] {
        previewCharacters ?? characters
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if isLoading && previewCharacters == nil {
                    loadingView
                } else if displayCharacters.isEmpty {
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
            .searchable(text: $searchText, prompt: "Search characters...")
            .sheet(isPresented: $showingFilters) {
                FilterView(filters: $filters)
            }
            .onAppear {
                // Only load data if we'rent in preview mode.
                if previewCharacters == nil {
                    loadMockData()
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
                await refreshData()
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
                
                Button("Load Mock Data") {
                    loadMockData()
                }
                .buttonStyle(.bordered)
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
    
    private func loadMockData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            characters = CharacterMock.charactersMocks
            isLoading = false
        }
    }
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        characters = CharacterMock.charactersMocks.shuffled()
    }
}

// MARK: - Previews Mejorados
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
