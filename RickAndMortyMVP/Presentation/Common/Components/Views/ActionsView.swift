//
//  ActionsView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 31/10/25.
//

import SwiftUI

// MARK: - Buttons UI components
struct ActionsView: View {
    let hasSelectedFilters: Bool
    let onApply: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            applyButton
            resetButton
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var applyButton: some View {
        Button(action: {
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            onApply()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text(String(localized:"apply_filters_button"))
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }
    
    @ViewBuilder
    private var resetButton: some View {
        if hasSelectedFilters {
            Button(action: {
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
                onReset()
            }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text(String(localized:"reset_filters_button"))
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}
