//
//  EpisodeRow.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUICore

struct EpisodeRow: View {
    let episodeURL: String
    let episodeNum: Int
    
    var body: some View {
        HStack {
            Image(systemName: "play.tv")
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text("Episode \(episodeNum)")
                    .fontWeight(.medium)
                Text(episodeCode)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var episodeCode: String {
        // Extraer código del episodio de la URL
        if let lastComponent = episodeURL.split(separator: "/").last {
            return "S01E\(lastComponent)"
        }
        return "S01E\(episodeNum)"
    }
}
