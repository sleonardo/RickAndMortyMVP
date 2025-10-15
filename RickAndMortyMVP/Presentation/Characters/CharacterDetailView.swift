//
//  CharacterDetailView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharacterDetailView: View {
    let character: RMCharacterModel
    @State private var isLoadingEpisodes = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                infoSection
                locationSection
                episodesSection
            }
            .padding()
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadMockEpisodeData()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Image placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 200)
                .overlay(
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(spacing: 8) {
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    statusIndicator
                    Text("\(character.status) - \(character.species)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(character.statusColor)
            .frame(width: 12, height: 12)
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Information")
                .font(.title2)
                .fontWeight(.semibold)
            
            InfoRow(icon: "person.text.rectangle", title: "Gender", value: character.gender)
            InfoRow(icon: "circle.dashed", title: "Species", value: character.species)
            
            if !character.type.isEmpty {
                InfoRow(icon: "tag", title: "Type", value: character.type)
            } else {
                InfoRow(icon: "tag", title: "Type", value: "Unknown")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(.title2)
                .fontWeight(.semibold)
            
            InfoRow(icon: "globe", title: "Origin", value: character.origin.name)
            InfoRow(icon: "mappin.and.ellipse", title: "Last Known", value: character.location.name)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Episodes")
                .font(.title2)
                .fontWeight(.semibold)
            
            if isLoadingEpisodes {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { episodeNum in
                        EpisodeRow(episodeNum: episodeNum)
                    }
                }
                
                if !character.episode.isEmpty {
                    Text("And \(character.episode.count - 5) more episodes...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func loadMockEpisodeData() {
        isLoadingEpisodes = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoadingEpisodes = false
        }
    }
}
