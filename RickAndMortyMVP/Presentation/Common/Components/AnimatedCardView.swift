//
//  AnimatedCardView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import SwiftUICore

// MARK: - UI components
struct AnimatedCardView<Content: View>: View {
    let delay: Double
    let content: Content
    
    @State private var opacity: Double = 0
    @State private var translation: CGFloat = 20
    
    init(delay: Double = 0, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }
    
    var body: some View {
        content
            .opacity(opacity)
            .offset(y: translation)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    opacity = 1
                    translation = 0
                }
            }
    }
}
