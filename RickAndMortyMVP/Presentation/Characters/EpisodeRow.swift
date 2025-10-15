//
//  EpisodeRow.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUICore

struct EpisodeRow: View {
    let episodeNum: Int
    
    var body: some View {
        HStack {
            Image(systemName: "play.tv")
                .foregroundColor(.green)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text("Episode \(episodeNum)")
                    .fontWeight(.medium)
                Text("S01E\(episodeNum)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(8)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
