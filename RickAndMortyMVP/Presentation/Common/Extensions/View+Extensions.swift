//
//  View+Extensions.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import SwiftUICore

// MARK: - View Extension for Easy Usage
extension View {
    func errorBanner(isPresented: Binding<Bool>, error: String?, errorType: ErrorBanner.ErrorType = .general, onRetry: (() -> Void)? = nil) -> some View {
        overlay(
            Group {
                if isPresented.wrappedValue, let error = error {
                    VStack {
                        ErrorBanner(error: error, errorType: errorType, onRetry: onRetry) {
                            isPresented.wrappedValue = false
                        }
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
                }
            }
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }
    
    func rickAndMortyGradient() -> some View {
        self.background(
            LinearGradient(
                colors: [Color.white.opacity(0.6), Color.orange.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }
}
