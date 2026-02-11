//
//  VerseCacheService.swift
//  Bible App
//

import Foundation

/// A service for caching Bible verses locally for offline access.
/// Uses UserDefaults for persistence with automatic expiration.
actor VerseCacheService {
    
    // MARK: - Singleton
    
    static let shared = VerseCacheService()
    
    // MARK: - Types
    
    private struct CacheEntry: Codable {
        let response: BibleResponse
        let cachedAt: Date
        let expiresAt: Date
    }
    
    // MARK: - Properties
    
    private let defaults = UserDefaults.standard
    private let cacheKey = "com.bibleapp.verseCache"
    private let dailyVerseKey = "com.bibleapp.dailyVerseCache"
    
    /// Cache expiration time in hours
    private let cacheExpirationHours: Double = 24
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Caches a Bible response for a specific reference
    func cache(_ response: BibleResponse, for reference: String) {
        let normalizedReference = normalizeReference(reference)
        let entry = CacheEntry(
            response: response,
            cachedAt: Date(),
            expiresAt: Date().addingTimeInterval(cacheExpirationHours * 3600)
        )
        
        var cache = loadCache()
        cache[normalizedReference] = entry
        saveCache(cache)
    }
    
    /// Caches the daily verse with today's date as key
    func cacheDailyVerse(_ response: BibleResponse) {
        let todayKey = dailyVerseCacheKey(for: Date())
        cache(response, for: todayKey)
        
        // Also store as "dailyVerse" for easy access
        let entry = CacheEntry(
            response: response,
            cachedAt: Date(),
            expiresAt: endOfToday()
        )
        
        var cache = loadCache()
        cache["dailyVerse"] = entry
        saveCache(cache)
    }
    
    /// Retrieves a cached response for a reference if it exists and hasn't expired
    func getCached(for reference: String) -> BibleResponse? {
        let normalizedReference = normalizeReference(reference)
        let cache = loadCache()
        
        guard let entry = cache[normalizedReference] else { return nil }
        
        // Check if expired
        if Date() > entry.expiresAt {
            return nil
        }
        
        return entry.response
    }
    
    /// Retrieves today's cached daily verse
    func getCachedDailyVerse() -> BibleResponse? {
        let cache = loadCache()
        
        guard let entry = cache["dailyVerse"] else { return nil }
        
        // Check if it's still today
        if !Calendar.current.isDateInToday(entry.cachedAt) {
            return nil
        }
        
        return entry.response
    }
    
    /// Clears all cached verses
    func clearCache() {
        defaults.removeObject(forKey: cacheKey)
    }
    
    /// Clears expired entries from cache
    func clearExpiredEntries() {
        var cache = loadCache()
        let now = Date()
        
        cache = cache.filter { _, entry in
            now <= entry.expiresAt
        }
        
        saveCache(cache)
    }
    
    /// Returns the number of cached entries
    func cacheCount() -> Int {
        loadCache().count
    }
    
    // MARK: - Private Methods
    
    private func loadCache() -> [String: CacheEntry] {
        guard let data = defaults.data(forKey: cacheKey) else {
            return [:]
        }
        
        do {
            return try JSONDecoder().decode([String: CacheEntry].self, from: data)
        } catch {
            print("Failed to decode cache: \(error)")
            return [:]
        }
    }
    
    private func saveCache(_ cache: [String: CacheEntry]) {
        do {
            let data = try JSONEncoder().encode(cache)
            defaults.set(data, forKey: cacheKey)
        } catch {
            print("Failed to encode cache: \(error)")
        }
    }
    
    private func normalizeReference(_ reference: String) -> String {
        reference.lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ":", with: "_")
    }
    
    private func dailyVerseCacheKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "daily_\(formatter.string(from: date))"
    }
    
    private func endOfToday() -> Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
    }
}

// MARK: - Network Status Monitor

/// Monitors network connectivity status
@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private(set) var isConnected = true
    private let queue = DispatchQueue(label: "com.bibleapp.networkMonitor")
    
    private init() {
        // Simple connectivity check - could be enhanced with NWPathMonitor
        checkConnection()
    }
    
    func checkConnection() {
        // Check if we can reach a simple endpoint
        guard let url = URL(string: "https://bible-api.com") else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, _ in
            DispatchQueue.main.async {
                self?.isConnected = (response as? HTTPURLResponse)?.statusCode == 200
            }
        }.resume()
    }
}
