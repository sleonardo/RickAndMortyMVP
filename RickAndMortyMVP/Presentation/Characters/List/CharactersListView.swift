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
    @StateObject private var viewModel: CharactersViewModel
    @State private var showingFilters = false
    @State private var showingCacheInfo = false
    
    init() {
        let useCases = DependencyContainer.shared.characterUseCases
        _viewModel = StateObject(wrappedValue: CharactersViewModel(useCases: useCases))
    }
    
    // Opción 2: Inicialización para testing/previews
    init(viewModel: CharactersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                
                if let error = viewModel.error {
                    errorBanner(error)
                }
            }
            .navigationTitle("Rick & Morty")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cacheInfoButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search characters...")
            .sheet(isPresented: $showingFilters) {
                FilterView(filters: $viewModel.filters)
            }
            .sheet(isPresented: $showingCacheInfo) {
                CacheInfoView(viewModel: viewModel)
            }
            .task {
                if viewModel.characters.isEmpty {
                    await viewModel.loadCharacters()
                }
                await viewModel.onAppear()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }
    
    private var characterList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.characters, id: \.uniqueID) { character in
                    NavigationLink {
                        CharacterDetailView(character: character)
                    } label: {
                        CharacterRow(character: character)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        // Load more data when reaching the end
                        if character.id == viewModel.characters.last?.id && !viewModel.isSearching {
                            Task {
                                await viewModel.loadCharacters()
                            }
                        }
                    }
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
            
            if viewModel.searchText.isEmpty && !viewModel.hasActiveFilters {
                Button("Load Characters") {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .buttonStyle(.bordered)
            } else {
                Button("Clear Search & Filters") {
                    Task {
                        await viewModel.clearSearchAndFilters()
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
    
    private func errorBanner(_ error: String) -> some View {
        VStack {
            HStack {
                Image(systemName: "exclamationmark.triangle")
                Text(error)
                    .font(.caption)
                Spacer()
                Button("Retry") {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: 1)
            )
            .padding(.horizontal)
            
            Spacer()
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
    
    private var cacheInfoButton: some View {
        Button {
            showingCacheInfo = true
        } label: {
            Image(systemName: "internaldrive")
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Cache Info View
struct CacheInfoView: View {
    @ObservedObject var viewModel: CharactersViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("Cache Statistics") {
                    HStack {
                        Text("Cached Items")
                        Spacer()
                        Text("\(viewModel.cacheStats.keys.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Cache Size")
                        Spacer()
                        Text(formatBytes(viewModel.cacheStats.size))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Cached Keys") {
                    if viewModel.cacheStats.keys.isEmpty {
                        Text("No cached items")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.cacheStats.keys.prefix(10), id: \.self) { key in
                            Text(key)
                                .font(.caption)
                        }
                        
                        if viewModel.cacheStats.keys.count > 10 {
                            Text("... and \(viewModel.cacheStats.keys.count - 10) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button("Clear Cache", role: .destructive) {
                        Task {
                            await viewModel.clearCache()
                            dismiss()
                        }
                    }
                    
                    Button("Refresh Stats") {
                        Task {
                            await viewModel.loadCacheStats()
                        }
                    }
                }
            }
            .navigationTitle("Cache Information")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Previews by status
#Preview("Normal State") {
    let viewModel = PreviewViewModelFactory.createNormalState()
    return CharactersListView(viewModel: viewModel)
}

#Preview("Empty State") {
    let viewModel = PreviewViewModelFactory.createEmptyState()
    return CharactersListView(viewModel: viewModel)
}

#Preview("Loading State") {
    let viewModel = PreviewViewModelFactory.createLoadingState()
    return CharactersListView(viewModel: viewModel)
}

#Preview("Error State") {
    let viewModel = PreviewViewModelFactory.createErrorState()
    return CharactersListView(viewModel: viewModel)
}

#Preview("Search State") {
    let viewModel = PreviewViewModelFactory.createSearchState()
    return CharactersListView(viewModel: viewModel)
}

#Preview("Filter State") {
    let viewModel = PreviewViewModelFactory.createFilterState()
    return CharactersListView(viewModel: viewModel)
}
