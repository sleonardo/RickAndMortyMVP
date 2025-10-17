//
//  MockCharacterRepository.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import Foundation
import RickMortySwiftApi

final class MockCharacterRepository: CharacterRepositoryProtocol {
    enum PreviewData {
        case success
        case loading
        case error
        case empty
    }

    private let state: PreviewData
    private let delayNanoseconds: UInt64

    init(previewData: PreviewData = .success, delayNanoseconds: UInt64 = 1_000_000_000) {
        self.state = previewData
        self.delayNanoseconds = delayNanoseconds
    }

    // MARK: - Network simulation
    private func simulateNetworkCall() async throws {
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
    }

    // MARK: - Protocol methods
    func getAllCharacters() async throws -> [RMCharacterModel] {
        try await simulateNetworkCall()

        switch state {
        case .success:
            return CharacterMock.charactersMocks
        case .empty:
            return CharacterMock.emptyMocks
        case .loading:
            try await Task.sleep(nanoseconds: 2_000_000_000)
            return CharacterMock.charactersMocks
        case .error:
            throw NSError(domain: "MockRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock network error"])
        }
    }

    func getCharacters(page: Int) async throws -> [RMCharacterModel] {
        try await simulateNetworkCall()

        switch state {
        case .error:
            throw NSError(domain: "MockRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock pagination error"])
        case .empty:
            return []
        default:
            // Simulación simple de paginación
            let all = CharacterMock.charactersMocks
            let pageSize = 2
            let start = (page - 1) * pageSize
            let end = min(start + pageSize, all.count)
            if start >= all.count { return [] }
            return Array(all[start..<end])
        }
    }

    func getCharacter(id: Int) async throws -> RMCharacterModel {
        try await simulateNetworkCall()
        if state == .error {
            throw NSError(domain: "MockRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Character not found"])
        }

        guard let character = CharacterMock.charactersMocks.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Character not found"])
        }
        return character
    }

    func searchCharacters(name: String, status: RickMortySwiftApi.Status?, gender: RickMortySwiftApi.Gender?) async throws -> [RMCharacterModel] {
        try await simulateNetworkCall()
        if state == .error {
            throw NSError(domain: "MockRepository", code: 500, userInfo: [NSLocalizedDescriptionKey: "Search failed"])
        }

        let all = CharacterMock.charactersMocks
        return all.filter {
            (name.isEmpty || $0.name.localizedCaseInsensitiveContains(name)) &&
            (status == nil || $0.status.lowercased() == status?.rawValue.lowercased()) &&
            (gender == nil || $0.gender.lowercased() == gender?.rawValue.lowercased())
        }
    }

    func clearCache() async {
        // There is no cache in the mock.
    }

    func getCacheStats() async -> (keys: [String], size: Int64) {
        (["mock_character_1", "mock_character_2"], 1024)
    }
}
