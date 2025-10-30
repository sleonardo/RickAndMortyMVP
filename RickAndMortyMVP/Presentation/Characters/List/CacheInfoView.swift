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
                Section(String(localized:"cache_statistics_title")) {
                    HStack {
                        Text(String(localized:"cached_items_text"))
                        Spacer()
                        Text("\(viewModel.cacheStats.keys.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text(String(localized:"cache_size_text"))
                        Spacer()
                        Text(formatBytes(viewModel.cacheStats.size))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(String(localized:"cached_keys_title")) {
                    if viewModel.cacheStats.keys.isEmpty {
                        Text(String(localized:"no_cached_items_text"))
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
                    Button(String(localized:"clear_cache_button"), role: .destructive) {
                        Task {
                            isLoading = true
                            await viewModel.clearCache()
                            isLoading = false
                        }
                    }
                    .disabled(isLoading)
                    
                    Button(String(localized:"refresh_stats_button")) {
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
                            Text(String(localized:"updating_text"))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(String(localized:"cache_information_text"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized:"done_button")) {
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
