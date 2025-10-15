//
//  CharacterDetailView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct CharacterDetailView: View {
    let character: RMCharacterModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) { }
            .padding()
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
