//
//  APICacheManager.swift
//  Pokedex
//
//  Created by Alex Wang on 2024/6/23.
//

import Foundation

class APICacheManager:NSObject {
    private struct CacheData: Codable {
        let timestamp: Date
        let data: Data
    }
    
    private let cacheDuration: TimeInterval = 60 * 60
    
    public class var sharedInstance : APICacheManager {
        struct Static {
            static let instance : APICacheManager = APICacheManager()
        }
        
        return Static.instance
    }
    
    override init() {
        super.init()
        
    }
    
    private func cacheFilePath(fileName:String) -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
    
    public func saveCache(key:String, data: Data) {
        createCacheDirectoryIfNeeded(key: key)
        let fileURL = cacheFilePath(fileName: key)
        let cacheData = CacheData(timestamp: Date(), data: data)
        do {
            let encodedData = try JSONEncoder().encode(cacheData)
            try encodedData.write(to: fileURL)
        } catch {
            print("Failed to save cache: \(error)")
        }
    }
    
    public func loadCache(key:String) -> Data? {
        if isCacheExpired(key: key) {
            //remove data
            clearCache(key: key)
            return nil
        }
        
        let fileURL = cacheFilePath(fileName: key)
        do {
            let encodedData = try Data(contentsOf: fileURL)
            let cacheData = try JSONDecoder().decode(CacheData.self, from: encodedData)
            return cacheData.data
        } catch {
            print("Failed to load cache: \(error)")
            return nil
        }
    }
    
    private func createCacheDirectoryIfNeeded(key:String) {
        let fileURL = cacheFilePath(fileName: key)
        let directory = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error)")
            }
        }
    }
    
    private func isCacheExpired(key:String) -> Bool {
        let fileURL = cacheFilePath(fileName: key)
        do {
            let encodedData = try Data(contentsOf: fileURL)
            let cacheData = try JSONDecoder().decode(CacheData.self, from: encodedData)
            return Date().timeIntervalSince(cacheData.timestamp) > cacheDuration
        } catch {
            return true
        }
    }
    
    func clearCache(key:String) {
        let fileURL = cacheFilePath(fileName: key)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
}
