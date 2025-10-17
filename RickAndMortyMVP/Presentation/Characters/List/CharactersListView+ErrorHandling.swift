//
//  CharactersListView+ErrorHandling.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import SwiftUI

struct ErrorBannerView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding()
    }
}

// MARK: - Previews
#Preview("Background Gradient Only") {
    LinearGradient(
        colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    .ignoresSafeArea()
}
