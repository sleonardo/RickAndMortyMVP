//
//  APIError.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 30/10/25.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case timeout
    case unauthorized
    case notFound
    case serverError
    case unknown
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .httpError(let statusCode):
            return "Error HTTP: \(statusCode)"
        case .decodingError(let error):
            return "Error decodificando datos: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .timeout:
            return "Tiempo de espera agotado"
        case .unauthorized:
            return "No autorizado"
        case .notFound:
            return "Recurso no encontrado"
        case .serverError:
            return "Error del servidor"
        case .unknown:
            return "Error desconocido"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkError, .timeout:
            return "Verifica tu conexión a internet e intenta nuevamente"
        case .unauthorized:
            return "Por favor, inicia sesión nuevamente"
        case .notFound:
            return "El recurso solicitado no existe"
        case .serverError:
            return "El servidor está experimentando problemas. Intenta más tarde"
        default:
            return "Intenta nuevamente en unos momentos"
        }
    }
    
    // Helper for creating errors from status codes
    static func from(statusCode: Int) -> APIError {
        switch statusCode {
        case 400...499:
            switch statusCode {
            case 401:
                return .unauthorized
            case 404:
                return .notFound
            default:
                return .httpError(statusCode: statusCode)
            }
        case 500...599:
            return .serverError
        default:
            return .httpError(statusCode: statusCode)
        }
    }
}
