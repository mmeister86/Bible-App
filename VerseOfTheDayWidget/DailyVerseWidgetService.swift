import Foundation
import SwiftData
import OSLog

struct DailyVerseWidgetData: Codable {
    let reference: String
    let text: String
    let source: String?
    let bookName: String
    let chapter: Int
    let verse: Int
    let translationName: String
    let isFavorited: Bool
}

struct DailyVerseWidgetService {
    static let appGroupID = "group.dev.matthiasmeister.Bible-App"
    // Same keys as DailyVerseService in the main app
    static let verseDataKey = "shared.dailyVerseData"
    static let verseDateKey = "shared.dailyVerseDate"
    static let verseTranslationKey = "shared.dailyVerseTranslation"
    
    private let favoritesStore = WidgetFavoritesStore()
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetDailyVerse")
    private static let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetDailyVerse")

    private var sharedDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        if defaults == nil {
            logger.error("App Group defaults unavailable for \(Self.appGroupID, privacy: .public)")
        }
        return defaults
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    /// Get the user's selected translation from the main app's UserDefaults
    private var selectedTranslation: String {
        // Read from the same key that SettingsViewModel uses
        sharedDefaults?.string(forKey: "selectedTranslation") ?? "web"
    }

    func fetchDailyVerse() async -> DailyVerseWidgetData {
        logger.debug("Widget fetchDailyVerse start. selectedTranslation=\(selectedTranslation, privacy: .public)")

        // Check if cache is fresh with the SAME translation
        if isDailyVerseFresh(), let cached = cachedVerse() {
            // Verify cached verse matches current translation
            let cachedTranslation = sharedDefaults?.string(forKey: Self.verseTranslationKey) ?? "web"
            if cachedTranslation == selectedTranslation {
                logger.debug("Using fresh cached verse: \(cached.reference, privacy: .public) (translation: \(cachedTranslation, privacy: .public))")
                return enrichWithFavoriteStatus(cached)
            }
        }

        do {
            let fetchedVerse = try await fetchVerseFromAPI()
            cache(verseData: fetchedVerse.rawData, translation: fetchedVerse.translationId)
            logger.debug("Fetched new verse from API: \(fetchedVerse.verse.reference, privacy: .public)")
            return enrichWithFavoriteStatus(fetchedVerse.verse)
        } catch {
            logger.error("Failed fetching verse from API: \(error.localizedDescription, privacy: .public)")
            if let cached = cachedVerse() {
                logger.debug("Using stale cached verse after fetch failure: \(cached.reference, privacy: .public)")
                return enrichWithFavoriteStatus(cached)
            }

            return DailyVerseWidgetData(
                reference: "Verse unavailable",
                text: "Unable to load today's verse.",
                source: nil,
                bookName: "",
                chapter: 0,
                verse: 0,
                translationName: "",
                isFavorited: false
            )
        }
    }

    func placeholderVerse() -> DailyVerseWidgetData {
        DailyVerseWidgetData(
            reference: "John 3:16",
            text: "For God so loved the world, that he gave his only born Son, that whoever believes in him should not perish, but have eternal life.",
            source: "World English Bible",
            bookName: "John",
            chapter: 3,
            verse: 16,
            translationName: "World English Bible",
            isFavorited: false
        )
    }

    func nextRefreshDate(from now: Date = Date()) -> Date {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: now) else {
            return now.addingTimeInterval(60 * 60 * 24)
        }

        let startOfTomorrow = Calendar.current.startOfDay(for: next)
        return Calendar.current.date(byAdding: .minute, value: 5, to: startOfTomorrow) ?? startOfTomorrow
    }

    private func fetchVerseFromAPI() async throws -> (verse: DailyVerseWidgetData, translationId: String, rawData: Data) {
        let translation = selectedTranslation
        guard let url = URL(string: "https://bible-api.com/?random=verse&translation=\(translation)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let apiResponse = try decoder.decode(WidgetBibleResponse.self, from: data)

        return (
            DailyVerseWidgetData(
                reference: apiResponse.reference,
                text: apiResponse.text.trimmingCharacters(in: .whitespacesAndNewlines),
                source: apiResponse.translationName,
                bookName: apiResponse.verses.first?.bookName ?? parsedBookName(from: apiResponse.reference),
                chapter: apiResponse.verses.first?.chapter ?? parsedChapter(from: apiResponse.reference),
                verse: apiResponse.verses.first?.verse ?? parsedVerse(from: apiResponse.reference),
                translationName: apiResponse.translationName ?? "",
                isFavorited: false
            ),
            translation,
            data
        )
    }

    private func cachedVerse() -> DailyVerseWidgetData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Self.verseDataKey) else {
            logger.debug("No cached verse data found in shared defaults")
            return nil
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let cached = try? decoder.decode(WidgetBibleResponse.self, from: data) else {
            logger.error("Cached verse decode failed")
            return nil
        }

        return DailyVerseWidgetData(
            reference: cached.reference,
            text: cached.text.trimmingCharacters(in: .whitespacesAndNewlines),
            source: cached.translationName,
            bookName: cached.verses.first?.bookName ?? parsedBookName(from: cached.reference),
            chapter: cached.verses.first?.chapter ?? parsedChapter(from: cached.reference),
            verse: cached.verses.first?.verse ?? parsedVerse(from: cached.reference),
            translationName: cached.translationName ?? "",
            isFavorited: false
        )
    }

    private func enrichWithFavoriteStatus(_ verse: DailyVerseWidgetData) -> DailyVerseWidgetData {
        let isFavorited = favoritesStore.isFavorited(reference: verse.reference)
        return DailyVerseWidgetData(
            reference: verse.reference,
            text: verse.text,
            source: verse.source,
            bookName: verse.bookName,
            chapter: verse.chapter,
            verse: verse.verse,
            translationName: verse.translationName,
            isFavorited: isFavorited
        )
    }

    private func parsedBookName(from reference: String) -> String {
        let parts = reference.split(separator: ":", maxSplits: 1)
        guard let leftSide = parts.first else { return "" }
        let tokens = leftSide.split(separator: " ")
        guard tokens.count >= 2 else { return String(leftSide) }
        return tokens.dropLast().joined(separator: " ")
    }

    private func parsedChapter(from reference: String) -> Int {
        let chapterPart = reference
            .split(separator: ":", maxSplits: 1)
            .first?
            .split(separator: " ")
            .last
        return Int(chapterPart ?? "") ?? 0
    }

    private func parsedVerse(from reference: String) -> Int {
        let versePart = reference
            .split(separator: ":", maxSplits: 1)
            .last?
            .split(separator: "-")
            .first
        return Int(versePart ?? "") ?? 0
    }

    private func cache(verseData: Data, translation: String) {
        guard let defaults = sharedDefaults else {
            return
        }

        defaults.set(verseData, forKey: Self.verseDataKey)
        defaults.set(todayString(), forKey: Self.verseDateKey)
        defaults.set(translation, forKey: Self.verseTranslationKey)
    }

    static func cacheVerseForToday(
        reference: String,
        text: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        translationName: String,
        translationId: String
    ) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else {
            logger.error("App Group defaults unavailable for \(appGroupID, privacy: .public)")
            return
        }
        let payload = WidgetBibleResponse(
            reference: reference,
            text: text,
            translationName: translationName,
            verses: [WidgetVerseEntry(bookName: bookName, chapter: chapter, verse: verse)]
        )

        guard let data = try? JSONEncoder().encode(payload) else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        defaults.set(data, forKey: verseDataKey)
        defaults.set(formatter.string(from: Date()), forKey: verseDateKey)
        defaults.set(translationId, forKey: verseTranslationKey)
    }

    private func isDailyVerseFresh() -> Bool {
        guard let defaults = sharedDefaults,
              let cachedDate = defaults.string(forKey: Self.verseDateKey) else {
            return false
        }

        return cachedDate == todayString()
    }

    private func todayString() -> String {
        dateFormatter.string(from: Date())
    }
}

private struct WidgetBibleResponse: Codable {
    let reference: String
    let text: String
    let translationName: String?
    let verses: [WidgetVerseEntry]
}

private struct WidgetVerseEntry: Codable {
    let bookName: String
    let chapter: Int
    let verse: Int
}
