//
//  CharacterEndpoint.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 30/10/25.
//

import Foundation

enum CharacterEndpoint: APIEndpoint {
    case getCharacters(page: Int, filters: [String: String]?)
    case getCharacter(id: Int)
    case getMultipleCharacters(ids: [Int])
    
    var path: String {
        switch self {
        case .getCharacters:
            return "/character"
        case .getCharacter(let id):
            return "/character/\(id)"
        case .getMultipleCharacters(let ids):
            let idsString = ids.map { String($0) }.joined(separator: ",")
            return "/character/\(idsString)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getCharacters(let page, let filters):
            var params: [String: String] = ["page": "\(page)"]
            if let filters = filters {
                params.merge(filters) { (current, _) in current }
            }
            return params
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
