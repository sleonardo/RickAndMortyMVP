//
//  ErrorUseCase.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 17/10/25.
//

import Foundation

// MARK: - UseCase Error
enum ErrorUseCase: Error, LocalizedError {
    case notFound
    case networkError
    case invalidData
    case cacheError
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested resource was not found."
        case .networkError:
            return "Network connection error. Please check your internet."
        case .invalidData:
            return "The data received is invalid."
        case .cacheError:
            return "Error accessing cache."
        }
    }
}
