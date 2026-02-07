//
//  DailyVerseService.swift
//  Bible App
//

import Foundation

/// Manages daily verse selection with UserDefaults caching.
/// Ensures one verse per calendar day — fetches a new random verse only when the cached date is stale.
struct DailyVerseService {

    private static let dailyVerseDataKey = "dailyVerseData"
    private static let dailyVerseDateKey = "dailyVerseDate"

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
        guard let data = UserDefaults.standard.data(forKey: dailyVerseDataKey) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(BibleResponse.self, from: data)
    }

    /// Cache the given response as today's daily verse
    static func cacheDailyVerse(_ response: BibleResponse) {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let data = try? encoder.encode(response) {
            UserDefaults.standard.set(data, forKey: dailyVerseDataKey)
            UserDefaults.standard.set(todayString, forKey: dailyVerseDateKey)
        }
    }

    /// Returns true if the cached verse date matches today
    static func isDailyVerseFresh() -> Bool {
        guard let cachedDate = UserDefaults.standard.string(forKey: dailyVerseDateKey) else {
            return false
        }
        return cachedDate == todayString
    }

    /// Returns today's verse — from cache if fresh, otherwise fetches a new random verse and caches it
    /// - Parameter translation: Translation ID (default: "web")
    /// - Returns: The daily `BibleResponse`
    static func fetchAndCacheDailyVerse(
        translation: String = "web"
    ) async throws -> BibleResponse {
        if isDailyVerseFresh(), let cached = getCachedDailyVerse() {
            return cached
        }

        let response = try await BibleAPIClient.fetchRandomVerse(translation: translation)
        cacheDailyVerse(response)
        return response
    }
}
