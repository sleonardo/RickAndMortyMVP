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
    
    // MARK: - Private Properties
    @State private var episodeCharacters: [RMCharacterModel] = []
    @State private var isLoadingEpisodes = false
    @State private var showFullEpisodes = false
    
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
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var episodesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Episodes")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if character.episode.count > 5 {
                    Button(showFullEpisodes ? "Show Less" : "Show All") {
                        withAnimation {
                            showFullEpisodes.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            
            if isLoadingEpisodes {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                LazyVStack(spacing: 8) {
                    let episodesToShow = showFullEpisodes ? character.episode : Array(character.episode.prefix(5))
                    
                    ForEach(Array(episodesToShow.enumerated()), id: \.offset) { index, episodeURL in
                        EpisodeRow(episodeURL: episodeURL, episodeNum: index + 1)
                    }
                }
                
                if character.episode.count > 5 && !showFullEpisodes {
                    Text("And \(character.episode.count - 5) more episodes...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func loadMockEpisodeData() {
        isLoadingEpisodes = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isLoadingEpisodes = false
        }
    }
}

// MARK: - Previews
#Preview("Character Detail - Rick Sanchez") {
    NavigationView {
        CharacterDetailView(character: CharacterMock.rickSanchezCharacter)
    }
}

#Preview("Character Detail - Morty Smith") {
    NavigationView {
        CharacterDetailView(character: CharacterMock.mortySmithCharacter)
    }
}

#Preview("Character Detail - Summer Smith") {
    NavigationView {
        CharacterDetailView(character: CharacterMock.summerSmithCharacter)
    }
}

#Preview("Character Detail - Beth Smith") {
    NavigationView {
        CharacterDetailView(character: CharacterMock.bethSmithCharacter)
    }
}

#Preview("Character Detail - Jerry Smith") {
    NavigationView {
        CharacterDetailView(character: CharacterMock.jerrySmithCharacter)
    }
}

#Preview("Character Detail - Loading Episodes") {
    struct LoadingPreview: View {
        var body: some View {
            NavigationView {
                CharacterDetailView(character: CharacterMock.rickSanchezCharacter)
                    .onAppear {
                        // Keep loading status
                    }
            }
        }
    }
    return LoadingPreview()
}

#Preview("Character Detail - Many Episodes") {
    let characterWithManyEpisodes = CharacterMock.createCharacterWithManyEpisodes()
    
    NavigationView {
        CharacterDetailView(character: characterWithManyEpisodes)
    }
}

#Preview("Character Detail - Unknown Status") {
    let unknownCharacter = CharacterMock.createCharacterWithUnknownStatus()
    
    NavigationView {
        CharacterDetailView(character: unknownCharacter)
    }
}
