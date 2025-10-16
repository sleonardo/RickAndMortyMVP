//
//  String+Extensions.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

// Helper for secure file names
extension String {
    var sanitizedFileName: String {
        return self
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "=", with: "_")
            .replacingOccurrences(of: "&", with: "_")
    }
}
