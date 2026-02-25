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
            logger.debug("No cached daily verse data found")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(BibleResponse.self, from: data)
        } catch {
            logger.error("Failed to decode cached daily verse as BibleResponse: \(error.localizedDescription, privacy: .public)")

            if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let keys = jsonObject.keys.sorted().joined(separator: ",")
                let hasTranslationId = jsonObject["translation_id"] != nil || jsonObject["translationId"] != nil
                let hasTranslationNote = jsonObject["translation_note"] != nil || jsonObject["translationNote"] != nil
                logger.error(
                    "Cached payload keys=\(keys, privacy: .public) hasTranslationId=\(hasTranslationId, privacy: .public) hasTranslationNote=\(hasTranslationNote, privacy: .public)"
                )
            }

            return nil
        }
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
            logger.debug(
                "Cached shared daily verse reference=\(response.reference, privacy: .public) translation=\(response.translationId, privacy: .public)"
            )
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
                logger.debug(
                    "Returning shared cached daily verse reference=\(cached.reference, privacy: .public) translation=\(translation, privacy: .public)"
                )
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
