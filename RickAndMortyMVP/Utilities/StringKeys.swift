//
//  StringKeys.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import Foundation
import RickMortySwiftApi

enum StringKeys {
    
    // MARK: - CacheService
    enum CacheService {
        static let cacheDirectory = String(
            localized: "cache_directory",
            comment: "Cache directory"
        )
        
        static let cachedCharacters = String(
            localized: "cached_characters",
            comment: "Cached characters"
        )
        
        static func characterforKey(_ characterId: Int) -> String {
            return String(
                localized: "character_\(characterId)",
                comment: "Character ID"
            )
        }
    }
    
    // MARK: - CacheService
    enum CharacterRepository {
        static let cachedCharacters = String(
            localized: "cached_characters",
            comment: "Cached characters"
        )
        
        static func charactersPage(_ page: Int) -> String {
            return String(
                localized: "characters_page_\(page)",
                comment: "Characters Page"
            )
        }
    }
    
    // MARK: - CharactersList
    enum CharactersList {
        static let searchCharacters = String(
            localized: "search_characters",
            comment: "Search characters..."
        )
    }
}
