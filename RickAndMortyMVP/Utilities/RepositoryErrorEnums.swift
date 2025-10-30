//
//  RepositoryErrorEnums.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import Foundation

// MARK: - Repository Error
enum RepositoryError: Error, LocalizedError {
    case notFound
    case networkError
    case invalidData
    case cacheError
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return String(
                localized: "not_found_error_message",
                comment: "The requested resource was not found."
            )
        case .networkError:
            return String(
                localized: "network_error_message",
                comment: "Network connection error. Please check your internet."
            )
        case .invalidData:
            return String(
                localized: "invalid_data_error_message",
                comment: "The data received is invalid."
            )
        case .cacheError:
            return String(
                localized: "cache_error_message",
                comment: "Error accessing cached data."
            )
        }
    }
}
