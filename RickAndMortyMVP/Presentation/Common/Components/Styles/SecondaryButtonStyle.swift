//
//  SecondaryButtonStyle.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 31/10/25.
//

import SwiftUI

// MARK: - Button Style components
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .foregroundColor(.red)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.red, lineWidth: 2)
                    .background(Color.red.opacity(0.1))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
