//
//  EnunStatus+Extensions.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import RickMortySwiftApi

extension Status {
    // To exclude “unknown” from the filters, you can create a calculated property.
    static var filterCasesStatus: [Status] {
        return [.alive, .dead] // Excluye unknown
    }
}

extension Gender {
    // To exclude “unknown” from filters
    static var filterCasesGender: [Gender] {
        return [.female, .male, .genderless] // Excluye unknown
    }
}
