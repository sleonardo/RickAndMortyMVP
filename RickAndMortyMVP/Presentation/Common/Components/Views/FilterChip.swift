//
//  FilterChip.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import SwiftUI

// MARK: - Filter Chip Component
struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.2))
        .clipShape(Capsule())
    }
}
