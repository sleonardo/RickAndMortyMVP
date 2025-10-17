//
//  CharactersListView+Background.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import SwiftUI

extension CharactersListView {
    var backgroundGradient: some View {
        LinearGradient(
            colors: [Color.white.opacity(0.6), Color.orange.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
