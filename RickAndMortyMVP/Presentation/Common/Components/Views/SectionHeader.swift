//
//  SectionHeader.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import SwiftUICore

// MARK: - UI components
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Circle()
                .fill(Color.blue)
                .frame(width: 6, height: 6)
                .opacity(0.8)
        }
        .padding(.bottom, 4)
    }
}
