//
//  PreviewCharacterRepository.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import Foundation
import RickMortySwiftApi

// MARK: - Preview Repository Classes
class PreviewCharacterRepository: CharacterRepositoryProtocol {
    private let characters: [RMCharacterModel]
    private let shouldThrowError: Bool
    private let delay: TimeInterval
    
    init(
        characters: [RMCharacterModel] = [],
        shouldThrowError: Bool = false,
        delay: TimeInterval = 1.0
    ) {
        self.characters = characters
        self.shouldThrowError = shouldThrowError
        self.delay = delay
    }
    
    func getAllCharacters() async throws -> [RMCharacterModel] {
        try await simulateDelay()
        if shouldThrowError {
            throw PreviewError.networkError
        }
        return characters
    }
    
    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        if shouldThrowError {
            throw PreviewError.networkError
        }
        
        // Simulate simple pagination
        let pageSize = 5
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, characters.count)
        
        if startIndex >= characters.count {
            return []
        }
        
        return Array(characters[startIndex..<endIndex])
    }
    
    func getCharacter(id: Int) async throws -> RMCharacterModel {
        try await simulateDelay()
        if shouldThrowError {
            throw PreviewError.characterNotFound
        }
        
        guard let character = characters.first(where: { $0.id == id }) else {
            throw PreviewError.characterNotFound
        }
        
        return character
    }
    
    func searchCharacters(name: String, status: Status?, gender: Gender?) async throws -> [RMCharacterModel] {
        try await simulateDelay()
        if shouldThrowError {
            throw PreviewError.searchFailed
        }
        
        return characters.filter { character in
            let matchesName = name.isEmpty || character.name.localizedCaseInsensitiveContains(name)
            let matchesStatus = status == nil || character.status.lowercased() == status?.rawValue.lowercased()
            let matchesGender = gender == nil || character.gender.lowercased() == gender?.rawValue.lowercased()
            
            return matchesName && matchesStatus && matchesGender
        }
    }
    
    func clearCache() async { }
    
    func getCacheStats() async -> (keys: [String], size: Int64) {
        return (["preview_data"], 1024)
    }
    
    private func simulateDelay() async throws {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
}

// MARK: - Specialized Preview Repositories
class EmptyCharacterRepository: PreviewCharacterRepository {
    init(delay: TimeInterval = 1.0) {
        super.init(characters: [], shouldThrowError: false, delay: delay)
    }
}

class LoadingCharacterRepository: PreviewCharacterRepository {
    init() {
        super.init(characters: [], shouldThrowError: false, delay: 10.0) // 10 seconds
    }
}

class ErrorCharacterRepository: PreviewCharacterRepository {
    init() {
        super.init(characters: [], shouldThrowError: true, delay: 1.0)
    }
}

class SuccessCharacterRepository: PreviewCharacterRepository {
    init(characters: [RMCharacterModel] = CharacterMock.charactersMocks) {
        super.init(characters: characters, shouldThrowError: false, delay: 1.0)
    }
}

// MARK: - Preview Errors
enum PreviewError: Error, LocalizedError {
    case networkError
    case characterNotFound
    case searchFailed
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .characterNotFound:
            return "Character not found"
        case .searchFailed:
            return "Search operation failed"
        }
    }
}
