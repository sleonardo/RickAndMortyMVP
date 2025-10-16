//
//  Color+Extensions.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import SwiftUI
import RickMortySwiftApi

// MARK: - Extensions
extension Color {
    static let rickBlue = Color(red: 0.11, green: 0.56, blue: 0.95)
    static let mortyYellow = Color(red: 0.96, green: 0.82, blue: 0.19)
    static let portalGreen = Color(red: 0.22, green: 0.84, blue: 0.44)
}

extension RMCharacterModel {
    // Helper for determining the status color
    var statusColor: Color {
        switch status.lowercased() {
        case "alive": return .green
        case "dead": return .red
        case "unknown": return .orange
        default: return .gray
        }
    }
    
    var uniqueID: String {
        // Combine ID with name to ensure uniqueness even if there are duplicate IDs
        return "\(id)-\(name)"
    }
}
