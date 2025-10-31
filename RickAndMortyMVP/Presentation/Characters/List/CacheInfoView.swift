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
            ZStack {
                Color.clear.rickAndMortyGradient()
                
                List {
                    statisticsSection
                    cachedKeysSection
                    Section{
                        VStack(spacing: 12) {
                            actionsSection
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    loadingSection
                    
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
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
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                StatRow(
                    title: String(localized:"cached_items_text"),
                    value: "\(viewModel.cacheStats.keys.count)",
                    icon: "square.stack.3d.up.fill",
                    color: .blue
                )
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                StatRow(
                    title: String(localized:"cache_size_text"),
                    value: formatBytes(viewModel.cacheStats.size),
                    icon: "internaldrive.fill",
                    color: .green
                )
            }
            .padding(.vertical, 8)
        } header: {
            SectionHeader(title: String(localized:"cache_statistics_title"), icon: "chart.bar.fill")
        }
        .listRowBackground(Color(.systemBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    // MARK: - Cached Keys Section
    private var cachedKeysSection: some View {
        Section {
            if viewModel.cacheStats.keys.isEmpty {
                EmptyStateView(
                    title: String(localized:"no_cached_items_text"),
                    message: String(localized:"cache_is_currently_empty_text"),
                    systemImage: "folder.badge.questionmark"
                )
                .frame(height: 150)
            } else {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.cacheStats.keys.prefix(8), id: \.self) { key in
                        CacheKeyRow(key: key)
                    }
                    
                    if viewModel.cacheStats.keys.count > 8 {
                        Text(String(localized: "more_items_text\(viewModel.cacheStats.keys.count - 8)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
        } header: {
            SectionHeader(title: String(localized:"cached_keys_title"), icon: "key.fill")
        }
        .listRowBackground(Color(.systemBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        Section {
            VStack(spacing: 12) {
                ActionButton(
                    title: String(localized:"refresh_stats_button"),
                    icon: "arrow.clockwise",
                    style: PrimaryButtonStyle(),
                    isLoading: isLoading,
                    action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        Task {
                            isLoading = true
                            await viewModel.loadCacheStats()
                            isLoading = false
                        }
                    }
                )
                
                ActionButton(
                    title: String(localized:"clear_cache_button"),
                    icon: "trash.fill",
                    style: SecondaryButtonStyle(),
                    isLoading: isLoading,
                    action: {
                        let impactLight = UIImpactFeedbackGenerator(style: .light)
                        impactLight.impactOccurred()
                        Task {
                            isLoading = true
                            await viewModel.clearCache()
                            isLoading = false
                        }
                    }
                )
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Color(.systemBackground))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    // MARK: - Loading Section
    @ViewBuilder
    private var loadingSection: some View {
        if isLoading {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text(String(localized:"updating_text"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            }
            .listRowBackground(Color(.systemBackground))
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
