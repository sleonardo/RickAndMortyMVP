//
//  CharacterRow.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharacterRow: View {
    let character: RMCharacterModel
    @State private var image: UIImage?
    @State private var isLoadingImage = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Image with AsyncImage and animated placeholder
            characterImage
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            characterInfo
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
                .scaleEffect(0.9)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isLoadingImage)
    }
    
    private var characterImage: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            LinearGradient(
                                colors: [.gray.opacity(0.2), .gray.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    if isLoadingImage {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .onAppear {
                    loadImage()
                }
            }
        }
    }
    
    private var characterInfo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(character.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            HStack(spacing: 8) {
                statusIndicator
                Text("\(character.species) • \(character.gender)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Last location: \(character.location.name)")
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(character.statusColor)
            .frame(width: 8, height: 8)
            .scaleEffect(1.2)
    }
    
    func loadImage() {
        // Download image
        Task {
            isLoadingImage = true
            
            // Check cache
            if let cachedImage = await ImageCache.shared.get(forKey: character.image) {
                await MainActor.run {
                    self.image = cachedImage
                    self.isLoadingImage = false
                }
                return
            }
            
            // Load image if not in cache
            guard let url = URL(string: character.image) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let downloadedImage = UIImage(data: data) {
                    // Save to cache
                    await ImageCache.shared.set(downloadedImage, forKey: character.image)
                    
                    await MainActor.run {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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
