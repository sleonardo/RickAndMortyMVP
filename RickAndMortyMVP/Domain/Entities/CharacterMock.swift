//
//  CharacterMock.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi
import SwiftUICore

// Class wrapper for initializing with Character
class CharacterMock {
    static let rickSanchezCharacter = createCharacter(
        id: 1,
        name: "Rick Sanchez",
        status: "Alive",
        species: "Human",
        gender: "Male",
        origin: "Earth (C-137)",
        location: "Earth (Replacement Dimension)",
        image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg"
    )
    
    static let mortySmithCharacter = createCharacter(
        id: 2,
        name: "Morty Smith",
        status: "Alive",
        species: "Human",
        gender: "Male",
        origin: "Earth (C-137)",
        location: "Earth (Replacement Dimension)",
        image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg"
    )
    
    static let summerSmithCharacter = createCharacter(
        id: 3,
        name: "Summer Smith",
        status: "Alive",
        species: "Human",
        gender: "Female",
        origin: "Earth (Replacement Dimension)",
        location: "Earth (Replacement Dimension)",
        image: "https://rickandmortyapi.com/api/character/avatar/3.jpeg"
    )
    
    static let bethSmithCharacter = createCharacter(
        id: 4,
        name: "Beth Smith",
        status: "Alive",
        species: "Human",
        gender: "Female",
        origin: "Earth (Replacement Dimension)",
        location: "Earth (Replacement Dimension)",
        image: "https://rickandmortyapi.com/api/character/avatar/4.jpeg"
    )
    
    static let jerrySmithCharacter = createCharacter(
        id: 5,
        name: "Jerry Smith",
        status: "Alive",
        species: "Human",
        gender: "Male",
        origin: "Earth (Replacement Dimension)",
        location: "Earth (Replacement Dimension)",
        image: "https://rickandmortyapi.com/api/character/avatar/5.jpeg"
    )
    
    static var charactersMocks: [RMCharacterModel] {
        [rickSanchezCharacter, mortySmithCharacter, summerSmithCharacter, bethSmithCharacter, jerrySmithCharacter]
    }
    
    static var emptyMocks: [RMCharacterModel] {
        []
    }
    
    // MARK: - Character Creation Methods
    private static func createCharacter(
        id: Int,
        name: String,
        status: String,
        species: String,
        gender: String,
        origin: String,
        location: String,
        image: String,
        episode: [String] = []
    ) -> RMCharacterModel {
        let json = """
        {
            "id": \(id),
            "name": "\(name)",
            "status": "\(status)",
            "species": "\(species)",
            "type": "",
            "gender": "\(gender)",
            "origin": {
                "name": "\(origin)",
                "url": ""
            },
            "location": {
                "name": "\(location)", 
                "url": ""
            },
            "image": "\(image)",
            "episode": \(episode.isEmpty ? "[]" : formatEpisodes(episode)),
            "url": "",
            "created": "2017-11-04T18:48:46.250Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try! decoder.decode(RMCharacterModel.self, from: data)
    }
    
    // MARK: - Special Mock Characters
    
    static func createCharacterWithManyEpisodes() -> RMCharacterModel {
        let episodes = (1...15).map { "https://rickandmortyapi.com/api/episode/\($0)" }
        
        return createCharacter(
            id: 999,
            name: "Rick with Many Episodes",
            status: "Alive",
            species: "Human",
            gender: "Male",
            origin: "Earth (C-137)",
            location: "Earth (Replacement Dimension)",
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: episodes
        )
    }
    
    static func createCharacterWithUnknownStatus() -> RMCharacterModel {
        return createCharacter(
            id: 888,
            name: "Mystery Character",
            status: "unknown",
            species: "Alien",
            gender: "unknown",
            origin: "Unknown",
            location: "Somewhere in Space",
            image: "https://rickandmortyapi.com/api/character/avatar/8.jpeg",
            episode: ["https://rickandmortyapi.com/api/episode/1"]
        )
    }
    
    static func createDeadCharacter() -> RMCharacterModel {
        return createCharacter(
            id: 777,
            name: "Deceased Rick",
            status: "Dead",
            species: "Human",
            gender: "Male",
            origin: "Earth (C-137)",
            location: "Citadel of Ricks",
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: [
                "https://rickandmortyapi.com/api/episode/1",
                "https://rickandmortyapi.com/api/episode/2",
                "https://rickandmortyapi.com/api/episode/3"
            ]
        )
    }
    
    static func createAlienCharacter() -> RMCharacterModel {
        return createCharacter(
            id: 666,
            name: "Alien Morty",
            status: "Alive",
            species: "Alien",
            gender: "Male",
            origin: "Unknown Dimension",
            location: "Space Station",
            image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
            episode: [
                "https://rickandmortyapi.com/api/episode/10",
                "https://rickandmortyapi.com/api/episode/11"
            ]
        )
    }
    
    // MARK: - Helper Methods
    
    private static func formatEpisodes(_ episodes: [String]) -> String {
        let episodeStrings = episodes.map { "\"\($0)\"" }
        return "[\(episodeStrings.joined(separator: ", "))]"
    }
}

// Helper for determining the status color
extension RMCharacterModel {
    var statusColor: Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        default: return .gray
        }
    }
}

struct Filters {
    var status: Status?
    var gender: Gender?
    var species: String = ""
}
