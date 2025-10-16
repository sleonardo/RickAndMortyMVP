//
//  CacheInfoView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import Foundation
import SwiftUI

// MARK: - Cache Info View
struct CacheInfoView: View {
    @ObservedObject var viewModel: CharactersViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
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
                            .italic()
                    } else {
                        ForEach(viewModel.cacheStats.keys.prefix(10), id: \.self) { key in
                            Text(key)
                                .font(.caption)
                                .lineLimit(1)
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
                            isLoading = true
                            await viewModel.clearCache()
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)
                    
                    Button("Refresh Stats") {
                        Task {
                            isLoading = true
                            await viewModel.loadCacheStats()
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)
                }
                
                if isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Updating...")
                                .foregroundColor(.secondary)
                            Spacer()
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
            .task {
                await viewModel.loadCacheStats()
            }
            .refreshable {
                await viewModel.loadCacheStats()
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
