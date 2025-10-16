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
    @State private var searchIsActive = false
    
    init() {
        let useCases = DependencyContainer.shared.characterUseCases
        _viewModel = StateObject(wrappedValue: CharactersViewModel(useCases: useCases))
    }
    
    // Initialization for testing/previews
    init(viewModel: CharactersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle("Rick & Morty")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cacheInfoButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .searchable(
                text: $viewModel.searchText,
                isPresented: $searchIsActive, prompt: "Search characters..."
            )
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
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color(.systemBackground).opacity(0.8)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    @ViewBuilder
    private var contentView: some View {
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
    
    private var characterList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.characters, id: \.uniqueID) { character in
                    NavigationLink {
                        CharacterDetailView(character: character)
                    } label: {
                        CharacterRow(character: character)
                            .padding(.horizontal)
                            .onAppear {
                                // Load more data when reaching the end
                                if character.id == viewModel.characters.last?.id &&
                                   !viewModel.isSearching &&
                                   !viewModel.isLoading {
                                    Task {
                                        await viewModel.loadCharacters()
                                    }
                                }
                            }
                    }.buttonStyle(PlainButtonStyle())
                }
                
                if viewModel.isLoading && !viewModel.characters.isEmpty {
                    loadingFooter
                }
            }
            .padding(.vertical)
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8),
                   value: viewModel.characters.map { $0.id })
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.blue)
            
            VStack(spacing: 8) {
                Text("Loading Characters")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Exploring the multiverse...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 25) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
                .symbolEffect(.bounce, options: .repeating, value: viewModel.isLoading)
            
            VStack(spacing: 12) {
                Text("No characters found")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(viewModel.searchText.isEmpty ?
                     "Try searching for different characters" :
                     "No results for \"\(viewModel.searchText)\"")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if viewModel.searchText.isEmpty && !viewModel.hasActiveFilters {
                Button("Load Characters") {
                    Task {
                        await viewModel.refresh()
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Clear Search & Filters") {
                    Task {
                        await viewModel.clearSearchAndFilters()
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingFooter: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading more...")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(Capsule())
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func errorBanner(_ error: String) -> some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Something went wrong")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            .shadow(color: .orange.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var filterButton: some View {
        Button {
            withAnimation(.spring()) {
                showingFilters = true
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolVariant(viewModel.hasActiveFilters ? .fill : .none)
                .foregroundColor(viewModel.hasActiveFilters ? .blue : .primary)
                .scaleEffect(1.1)
        }
    }
    
    private var cacheInfoButton: some View {
        Button {
            showingCacheInfo = true
        } label: {
            Image(systemName: "internaldrive")
                .foregroundColor(.blue)
                .overlay(
                    Group {
                        if !viewModel.cacheStats.keys.isEmpty {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 6, y: -6)
                        }
                    }
                )
        }
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
