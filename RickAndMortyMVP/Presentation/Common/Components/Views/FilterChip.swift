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
    
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    onRemove()
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}
