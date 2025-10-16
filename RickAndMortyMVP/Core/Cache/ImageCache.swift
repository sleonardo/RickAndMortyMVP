//
//  ImageCache.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 16/10/25.
//

import UIKit
import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    private init() {
        memoryCache.countLimit = 100 // Maximum 100 images in memory
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        let directories = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = directories[0].appendingPathComponent("ImageCache")
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func get(forKey key: String) -> UIImage? {
        let memoryKey = key as NSString
        
        // Search memory first
        if let cachedImage = memoryCache.object(forKey: memoryKey) {
            return cachedImage
        }
        
        // Search local files
        let fileURL = cacheDirectory.appendingPathComponent(key.sanitizedFileName)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }
        
        // Save for future reference
        memoryCache.setObject(image, forKey: memoryKey)
        
        return image
    }
    
    func set(_ image: UIImage, forKey key: String) {
        let memoryKey = key as NSString
        memoryCache.setObject(image, forKey: memoryKey)
        
        // Save to disk in the background
        Task {
            let fileURL = cacheDirectory.appendingPathComponent(key.sanitizedFileName)
            if let data = image.jpegData(compressionQuality: 0.8) {
                try? data.write(to: fileURL)
            }
        }
    }
    
    func clear() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
