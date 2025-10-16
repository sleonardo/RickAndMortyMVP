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
    
    // MARK: - State Properties
    @State private var image: UIImage?
    @State private var isLoadingImage = true
    @State private var showFullEpisodes = false
    @State private var isLoadingEpisodes = false
    @State private var scaleEffect: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerSection
                    .padding(.bottom, 20)
                
                infoSection
                    .padding(.vertical, 16)
                
                locationSection
                    .padding(.vertical, 16)
                
                episodesSection
                    .padding(.vertical, 16)
            }
            .padding(.horizontal)
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            loadCharacterImage()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                scaleEffect = 1
                opacity = 1
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Character image
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(
                            color: character.statusColor.opacity(0.3),
                            radius: 15,
                            x: 0,
                            y: 8
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(character.statusColor.opacity(0.2), lineWidth: 2)
                        )
                        .scaleEffect(scaleEffect)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: scaleEffect)
                } else {
                    // Placeholder
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [.gray.opacity(0.2), .gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                        .overlay(
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.white)
                                Text("Loading image...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
                
                // Status badge
                statusBadge
                    .offset(x: 80, y: -80)
            }
            
            VStack(spacing: 12) {
                Text(character.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(character.statusColor)
                        .frame(width: 10, height: 10)
                        .scaleEffect(1.2)
                    
                    Text("\(character.status) • \(character.species)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            .opacity(opacity)
            .animation(.easeInOut(duration: 0.8).delay(0.3), value: opacity)
        }
    }
    
    private var statusBadge: some View {
        Text(character.status.uppercased())
            .font(.system(size: 10, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(character.statusColor)
                    .shadow(color: character.statusColor.opacity(0.5), radius: 4, x: 0, y: 2)
            )
    }
    
    private var infoSection: some View {
        AnimatedCardView(delay: 0.2) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Information", icon: "info.circle")
                
                LazyVStack(spacing: 12) {
                    InfoRow(icon: "person.text.rectangle", title: "Gender", value: character.gender)
                    InfoRow(icon: "circle.dashed", title: "Species", value: character.species)
                    
                    if !character.type.isEmpty {
                        InfoRow(icon: "tag", title: "Type", value: character.type)
                    } else {
                        InfoRow(icon: "tag", title: "Type", value: "Unknown")
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var locationSection: some View {
        AnimatedCardView(delay: 0.4) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(title: "Location", icon: "map")
                
                LazyVStack(spacing: 12) {
                    InfoRow(icon: "globe", title: "Origin", value: character.origin.name)
                    InfoRow(icon: "mappin.and.ellipse", title: "Last Known", value: character.location.name)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private var episodesSection: some View {
        AnimatedCardView(delay: 0.6) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SectionHeader(title: "Episodes", icon: "play.tv")
                    
                    Spacer()
                    
                    if character.episode.count > 5 {
                        Button(showFullEpisodes ? "Show Less" : "Show All") {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showFullEpisodes.toggle()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .buttonStyle(.plain)
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
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
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
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    private func loadCharacterImage() {
        // Download image
        Task {
            // Check cache
            if let cachedImage = await ImageCache.shared.get(forKey: character.image) {
                await MainActor.run {
                    self.image = cachedImage
                    self.isLoadingImage = false
                }
                return
            }
            
            // Load image if not in cache
            guard let url = URL(string: character.image) else {
                isLoadingImage = false
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let downloadedImage = UIImage(data: data) {
                    // Save to cache
                    await ImageCache.shared.set(downloadedImage, forKey: character.image)
                    
                    await MainActor.run {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            self.image = downloadedImage
                            self.isLoadingImage = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingImage = false
                }
            }
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
