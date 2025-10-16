//
//  CacheEntry.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import Foundation

// MARK: - Cache Entry
struct CacheEntry<T: Codable>: Codable {
    let value: T
    let expiryDate: Date
    let size: Int
    
    var isExpired: Bool {
        return Date() > expiryDate
    }
}
