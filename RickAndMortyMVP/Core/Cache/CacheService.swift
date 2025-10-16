//
//  CacheService.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import Foundation
import RickMortySwiftApi

actor CacheService: CacheServiceProtocol {
    
    // MARK: - Properties
    private let memoryCache = NSCache<NSString, AnyObject>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Constants
    private struct Constants {
        static let memoryCacheLimit = 100
        static let memoryCacheSizeLimit = 50 * 1024 * 1024 // 50MB
        static let defaultExpiry: CacheExpiry = .hours(24)
        static let charactersKey = StringKeys.CacheService.cachedCharacters
    }
    
    // MARK: - Initialization
    init() {
        // Configure memory cache
        memoryCache.countLimit = Constants.memoryCacheLimit
        memoryCache.totalCostLimit = Constants.memoryCacheSizeLimit
        
        // Setup cache directory
        let directories = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = directories[0].appendingPathComponent(StringKeys.CacheService.cacheDirectory)
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Setup JSON encoder/decoder
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Basic Cache Operations
    func set<T: Codable>(_ value: T, forKey key: String, expiry: CacheExpiry = Constants.defaultExpiry) {
        let entry = CacheEntry(
            value: value,
            expiryDate: expiry.date,
            size: calculateSize(of: value)
        )
        
        // Store in memory cache
        let memoryKey = key as NSString
        memoryCache.setObject(entry as AnyObject, forKey: memoryKey, cost: entry.size)
        
        // Store in disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = try? encoder.encode(entry) {
            try? data.write(to: fileURL)
        }
    }
    
    func get<T: Codable>(key: String) -> T? {
        let memoryKey = key as NSString
        
        // Try memory cache first
        if let cachedEntry = memoryCache.object(forKey: memoryKey) as? CacheEntry<T> {
            if cachedEntry.isExpired {
                remove(key: key)
                return nil
            }
            return cachedEntry.value
        }
        
        // Try disk cache
        let fileURL = cacheDirectory.appendingPathComponent(key)
        guard let data = try? Data(contentsOf: fileURL),
              let entry = try? decoder.decode(CacheEntry<T>.self, from: data) else {
            return nil
        }
        
        // Check expiry
        if entry.isExpired {
            remove(key: key)
            return nil
        }
        
        // Store back in memory cache
        memoryCache.setObject(entry as AnyObject, forKey: memoryKey, cost: entry.size)
        
        return entry.value
    }
    
    func remove(key: String) {
        let memoryKey = key as NSString
        memoryCache.removeObject(forKey: memoryKey)
        
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try? fileManager.removeItem(at: fileURL)
    }
    
    func clear() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func clearExpired() {
        // Clear expired from disk cache
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for fileURL in files {
            if let data = try? Data(contentsOf: fileURL),
               let entry = try? decoder.decode(CacheEntry<AnyCodable>.self, from: data),
               entry.isExpired {
                try? fileManager.removeItem(at: fileURL)
            }
        }
    }
    
    // MARK: - Advanced Operations
    func exists(key: String) -> Bool {
        let memoryKey = key as NSString
        if memoryCache.object(forKey: memoryKey) != nil {
            return true
        }
        
        let fileURL = cacheDirectory.appendingPathComponent(key)
        return fileManager.fileExists(atPath: fileURL.path)
    }
    
    func getKeys() -> [String] {
        guard let files = try? fileManager.contentsOfDirectory(atPath: cacheDirectory.path) else {
            return []
        }
        return files
    }
    
    func getSize() -> Int64 {
        guard let files = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        return files.reduce(0) { total, fileURL in
            let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
            return total + Int64(fileSize)
        }
    }
    
    // MARK: - Character Specific Helpers
    func getCharacters() -> [RMCharacterModel]? {
        return get(key: Constants.charactersKey)
    }
    
    func setCharacters(_ characters: [RMCharacterModel]) {
        set(characters, forKey: Constants.charactersKey, expiry: .hours(6))
    }
    
    func getCharacter(id: Int) -> RMCharacterModel? {
        return get(key: StringKeys.CacheService.characterforKey(id))
    }
    
    func setCharacter(_ character: RMCharacterModel) {
        set(character, forKey:  StringKeys.CacheService.characterforKey(character.id), expiry: .days(1))
    }
    
    // MARK: - Private Methods
    private func calculateSize<T: Codable>(of value: T) -> Int {
        return (try? encoder.encode(value))?.count ?? 0
    }
}

// MARK: - Helper for Any Codable
private struct AnyCodable: Codable {}
