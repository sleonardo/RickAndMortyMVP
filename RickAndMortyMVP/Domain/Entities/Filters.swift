//
//  Filters.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//
import Foundation
import RickMortySwiftApi

struct CharacterFilters {
    var status: Status?
    var gender: Gender?
    
    var hasActiveFilters: Bool {
        return status != nil || gender != nil
    }
    
    var description: String {
        var components: [String] = []
        if let status = status {
            components.append("Status: \(status.rawValue)")
        }
        if let gender = gender {
            components.append("Gender: \(gender.rawValue)")
        }
        return components.joined(separator: ", ")
    }
}
