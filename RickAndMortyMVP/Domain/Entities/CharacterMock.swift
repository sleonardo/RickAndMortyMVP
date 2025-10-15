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
    
    private static func createCharacter(
        id: Int,
        name: String,
        status: String,
        species: String,
        gender: String,
        origin: String,
        location: String,
        image: String
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
            "episode": [],
            "url": "",
            "created": "2017-11-04T18:48:46.250Z"
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        return try! decoder.decode(RMCharacterModel.self, from: data)
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
