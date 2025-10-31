//
//  AppEnvironment.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 31/10/25.
//

import Foundation

public struct AppEnvironment {
    private init() {}
    
    public enum Error: Swift.Error {
        case missingKey, invalidValue
    }
    
    public static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {

        if let infoDictionary = Bundle.main.infoDictionary {
            print("🔍 Info.plist keys: \(infoDictionary.keys.sorted())")
        }
        
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            print("❌ Missing key: \(key)")
            throw Error.missingKey
        }
        
        print("✅ Found key: \(key) = \(object)")
        
        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            print("❌ Invalid value for key: \(key) - \(object)")
            throw Error.invalidValue
        }
    }
    
    // Helpers
    public static var apiBaseURL: String {
        let url = (try? value(for: "API_BASE_URL")) ?? "https://dev.com/api"
        print("🌐 API Base URL: \(url)")
        return url
    }
    
    public static var isLoggingEnabled: Bool {
        return (try? value(for: "ENABLE_LOGGING")) ?? false
    }
    
    public static var isDebugMode: Bool {
        return (try? value(for: "DEBUG_MODE")) ?? false
    }
}
