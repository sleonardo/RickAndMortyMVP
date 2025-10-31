//
//  SearchBar.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import SwiftUI

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    let onSearch: (String) -> Void
    @ObservedObject var viewModel: CharactersViewModel
    @State private var isEditing = false
    @State private var searchTask: Task<Void, Never>?
    
    private let debounceDelay: UInt64 = 500_000_000 // 500ms
    
    var body: some View {
        HStack {
            TextField(StringKeys.CharactersList.searchCharacters,
                      text: $text)
                .padding(8)
                .padding(.horizontal, 32)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                clearSearch()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        self.isEditing = true
                    }
                }
                .onChange(of: text) { oldValue, newValue in
                    handleSearchTextChange(newValue)
                }
                .submitLabel(.search)
                .onSubmit {
                    // Search immediately when user presses Enter
                    searchTask?.cancel()
                    onSearch(text)
                }
            
            if isEditing {
                Button("Cancel") {
                    cancelSearch()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.spring(response: 0.3), value: isEditing)
            }
        }
    }
    
    private func handleSearchTextChange(_ newValue: String) {
        // Cancel previous search
        searchTask?.cancel()
        
        // If empty, immediately search for reset
        guard !newValue.isEmpty else {
            onSearch(newValue)
            return
        }
        
        // Create new search task with debounce
        searchTask = Task {
            // Wait before searching
            try? await Task.sleep(nanoseconds: debounceDelay)
            
            // Check if the task was canceled
            guard !Task.isCancelled else { return }
            
            // Run search
            await MainActor.run {
                onSearch(newValue)
            }
        }
    }
    
    private func clearSearch() {
        text = ""
        searchTask?.cancel()
        onSearch("")
    }
    
    private func cancelSearch() {
        withAnimation(.spring()) {
            isEditing = false
        }
        clearSearch()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    @Previewable @State var searchText = ""
    
    return VStack {
        SearchBar(
            text: $searchText,
            onSearch: { query in
                print("Searching for: \(query)")
            },
            viewModel: CharactersViewModel(
                useCases: CharacterUseCases(repository: MockCharacterRepository(previewData: .success))
            )
        )
        .padding()
        
        Text("Current text: \(searchText)")
            .padding()
    }
}
