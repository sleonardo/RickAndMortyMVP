//
//  CharactersListView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI

struct CharactersListView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                      .ignoresSafeArea()
            }
        }.navigationTitle("Rick & Morty")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {}
        }
    }
}

#Preview {
    CharactersListView()
}
