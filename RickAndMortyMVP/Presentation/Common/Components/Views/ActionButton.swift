//
//  ActionButton.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 31/10/25.
//

import SwiftUI

// MARK: - Buttons UI components
struct ActionButton<Style: ButtonStyle>: View {
    let title: String
    let icon: String
    let style: Style
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .fontWeight(.semibold)                
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(style)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
    }
}
