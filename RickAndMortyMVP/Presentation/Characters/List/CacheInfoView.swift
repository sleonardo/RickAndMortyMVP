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
