//
//  DailyVerseService.swift
//  Bible App
//

import Foundation
import OSLog

/// Manages daily verse selection with UserDefaults caching.
/// Ensures one verse per calendar day — fetches a new random verse only when the cached date is stale.
struct DailyVerseService {

    private static let appGroupID = "group.dev.matthiasmeister.Bible-App"
    private static let dailyVerseDataKey = "shared.dailyVerseData"
    private static let dailyVerseDateKey = "shared.dailyVerseDate"
    private static let dailyVerseTranslationKey = "shared.dailyVerseTranslation"
    private static let dailyVerseReferenceKey = "shared.dailyVerseReference"
    private static let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "DailyVerseService")

    private static var sharedDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: appGroupID)
        if defaults == nil {
            logger.error("App Group defaults unavailable for \(appGroupID, privacy: .public)")
        }
        return defaults
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    private static var todayString: String {
        dateFormatter.string(from: Date())
    }

    // MARK: - Public API

    /// Returns the cached daily verse if one exists, or nil
    static func getCachedDailyVerse() -> BibleResponse? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: dailyVerseDataKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(BibleResponse.self, from: data)
    }

    /// Cache the given response as today's daily verse
    static func cacheDailyVerse(_ response: BibleResponse) {
        guard let defaults = sharedDefaults else {
            return
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let data = try? encoder.encode(response) {
            defaults.set(data, forKey: dailyVerseDataKey)
            defaults.set(todayString, forKey: dailyVerseDateKey)
            defaults.set(response.translationId, forKey: dailyVerseTranslationKey)
            defaults.set(response.reference, forKey: dailyVerseReferenceKey)
        }
    }
    
    /// Returns the cached verse reference (e.g., "John 3:16") if one exists
    static func getCachedVerseReference() -> String? {
        sharedDefaults?.string(forKey: dailyVerseReferenceKey)
    }
    
    /// Fetch the same verse in a different translation and update the cache
    static func fetchAndCacheDailyVerseInNewTranslation(
        newTranslation: String
    ) async throws -> BibleResponse {
        // Get the cached reference to fetch the same verse in new translation
        guard let reference = getCachedVerseReference() else {
            // No cached reference, fall back to random verse
            logger.info("No cached reference found, fetching random verse for new translation")
            return try await fetchAndCacheDailyVerse(translation: newTranslation)
        }
        
        logger.info("Fetching same verse '\(reference, privacy: .public)' in new translation '\(newTranslation, privacy: .public)'")
        
        let response = try await BibleAPIClient.fetchVerse(
            reference: reference,
            translation: newTranslation
        )
        cacheDailyVerse(response)
        return response
    }

    /// Returns true if the cached verse date matches today AND uses the same translation
    static func isDailyVerseFresh(for translation: String) -> Bool {
        guard let defaults = sharedDefaults,
              let cachedDate = defaults.string(forKey: dailyVerseDateKey) else {
            return false
        }

        let cachedTranslation = defaults.string(forKey: dailyVerseTranslationKey) ?? "web"
        
        return cachedDate == todayString && cachedTranslation == translation
    }

    /// Returns today's verse — from cache if fresh, otherwise fetches a new random verse and caches it
    /// - Parameter translation: Translation ID (default: "web")
    /// - Returns: The daily `BibleResponse`
    static func fetchAndCacheDailyVerse(
        translation: String = "web"
    ) async throws -> BibleResponse {
        // Use the translation parameter - cache is only valid for the same translation
        if isDailyVerseFresh(for: translation), let cached = getCachedDailyVerse() {
            // Verify cached verse matches requested translation
            if cached.translationId == translation {
                return cached
            }
        }

        let response = try await BibleAPIClient.fetchRandomVerse(translation: translation)
        cacheDailyVerse(response)
        return response
    }
    
    /// Clears the cached daily verse to force a refresh
    static func clearCache() {
        guard let defaults = sharedDefaults else {
            return
        }

        defaults.removeObject(forKey: dailyVerseDataKey)
        defaults.removeObject(forKey: dailyVerseDateKey)
        defaults.removeObject(forKey: dailyVerseTranslationKey)
        defaults.removeObject(forKey: dailyVerseReferenceKey)
    }
}
