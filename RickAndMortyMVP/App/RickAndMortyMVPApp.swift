//
//  RickAndMortyMVPApp.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 14/10/25.
//

import SwiftUI
import RickMortySwiftApi

@main
struct RickAndMortyMVPApp: App {
    var body: some Scene {
        WindowGroup {
            CharactersListView(
                characterRepository: CharacterRepository(
                    rmClient: RMClient(),
                    cacheService: CacheService()
                )
            )
        }
    }
}
