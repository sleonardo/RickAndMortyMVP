//
//  CharactersListView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharactersListView: View {
    @State private var characters: [RMCharacterModel] = CharacterMock.charactersMocks
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var filters = Filters()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if characters.isEmpty {
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
                loadMockData()
            }
        }
    }
    
    private var characterList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(characters) { character in
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
    
    private var filterButton: some View {
        Button {
            showingFilters = true
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolRenderingMode(.multicolor)
        }
    }
    
    private func loadMockData() {
        characters = CharacterMock.charactersMocks
    }
    
    private func refreshData() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        characters = CharacterMock.charactersMocks.shuffled()
    }
}

// MARK: - Preview
#Preview("Character List with Data") {
    CharactersListView()
}
