import Foundation
import OSLog

struct RandomVerseWidgetData: Codable {
    let reference: String
    let text: String
    let source: String?
    let bookName: String
    let chapter: Int
    let verse: Int
    let translationName: String
    let isFavorited: Bool
}

struct RandomVerseWidgetService {
    static let appGroupID = "group.dev.matthiasmeister.Bible-App"
    static let randomVerseDataKey = "shared.randomVerseData"
    static let randomVerseTimestampKey = "shared.randomVerseTimestamp"
    static let randomVerseTranslationKey = "shared.randomVerseTranslation"

    private let favoritesStore = WidgetFavoritesStore()
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetRandomVerse")

    private var sharedDefaults: UserDefaults? {
        let defaults = UserDefaults(suiteName: Self.appGroupID)
        if defaults == nil {
            logger.error("App Group defaults unavailable for \(Self.appGroupID, privacy: .public)")
        }
        return defaults
    }

    private var selectedTranslation: String {
        sharedDefaults?.string(forKey: "selectedTranslation") ?? "web"
    }

    func fetchRandomVerse(forceRefresh: Bool = false) async -> RandomVerseWidgetData {
        logger.debug("Widget fetchRandomVerse start. selectedTranslation=\(selectedTranslation, privacy: .public)")

        if !forceRefresh, isRandomVerseFresh(), let cached = cachedVerse() {
            let cachedTranslation = sharedDefaults?.string(forKey: Self.randomVerseTranslationKey) ?? "web"
            if cachedTranslation == selectedTranslation {
                logger.debug("Using fresh random cache: \(cached.reference, privacy: .public)")
                return enrichWithFavoriteStatus(cached)
            }
        }

        do {
            let fetchedVerse = try await fetchVerseFromAPI()
            cache(verseData: fetchedVerse.rawData, translation: fetchedVerse.translationId)
            logger.debug("Fetched new random verse: \(fetchedVerse.verse.reference, privacy: .public)")
            return enrichWithFavoriteStatus(fetchedVerse.verse)
        } catch {
            logger.error("Failed fetching random verse: \(error.localizedDescription, privacy: .public)")
            if let cached = cachedVerse() {
                logger.debug("Using stale random cache after fetch failure: \(cached.reference, privacy: .public)")
                return enrichWithFavoriteStatus(cached)
            }

            return RandomVerseWidgetData(
                reference: "Verse unavailable",
                text: "Unable to load a random verse.",
                source: nil,
                bookName: "",
                chapter: 0,
                verse: 0,
                translationName: "",
                isFavorited: false
            )
        }
    }

    func placeholderVerse() -> RandomVerseWidgetData {
        RandomVerseWidgetData(
            reference: "Psalm 23:1",
            text: "Yahweh is my shepherd: I shall lack nothing.",
            source: "World English Bible",
            bookName: "Psalm",
            chapter: 23,
            verse: 1,
            translationName: "World English Bible",
            isFavorited: false
        )
    }

    func nextRefreshDate(from now: Date = Date()) -> Date {
        now.addingTimeInterval(60 * 60)
    }

    private func fetchVerseFromAPI() async throws -> (verse: RandomVerseWidgetData, translationId: String, rawData: Data) {
        let translation = selectedTranslation

        let apiResponse = try await BibleAPIClient.fetchRandomVerse(translation: translation)
        let data = try JSONEncoder().encode(apiResponse)

        return (
            RandomVerseWidgetData(
                reference: apiResponse.reference,
                text: apiResponse.text.trimmingCharacters(in: .whitespacesAndNewlines),
                source: apiResponse.translationName,
                bookName: apiResponse.verses.first?.bookName ?? parsedBookName(from: apiResponse.reference),
                chapter: apiResponse.verses.first?.chapter ?? parsedChapter(from: apiResponse.reference),
                verse: apiResponse.verses.first?.verse ?? parsedVerse(from: apiResponse.reference),
                translationName: apiResponse.translationName,
                isFavorited: false
            ),
            apiResponse.translationId,
            data
        )
    }

    private func cachedVerse() -> RandomVerseWidgetData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Self.randomVerseDataKey) else {
            logger.debug("No random cache data found in shared defaults")
            return nil
        }

        if let cached = try? JSONDecoder().decode(BibleResponse.self, from: data) {
            return RandomVerseWidgetData(
                reference: cached.reference,
                text: cached.text.trimmingCharacters(in: .whitespacesAndNewlines),
                source: cached.translationName,
                bookName: cached.verses.first?.bookName ?? parsedBookName(from: cached.reference),
                chapter: cached.verses.first?.chapter ?? parsedChapter(from: cached.reference),
                verse: cached.verses.first?.verse ?? parsedVerse(from: cached.reference),
                translationName: cached.translationName,
                isFavorited: false
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let legacyCached = try? decoder.decode(RandomWidgetBibleResponse.self, from: data) else {
            logger.error("Random cache decode failed")
            return nil
        }

        return RandomVerseWidgetData(
            reference: legacyCached.reference,
            text: legacyCached.text.trimmingCharacters(in: .whitespacesAndNewlines),
            source: legacyCached.translationName,
            bookName: legacyCached.verses.first?.bookName ?? parsedBookName(from: legacyCached.reference),
            chapter: legacyCached.verses.first?.chapter ?? parsedChapter(from: legacyCached.reference),
            verse: legacyCached.verses.first?.verse ?? parsedVerse(from: legacyCached.reference),
            translationName: legacyCached.translationName ?? "",
            isFavorited: false
        )
    }

    private func enrichWithFavoriteStatus(_ verse: RandomVerseWidgetData) -> RandomVerseWidgetData {
        let isFavorited = favoritesStore.isFavorited(reference: verse.reference)
        return RandomVerseWidgetData(
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

        defaults.set(verseData, forKey: Self.randomVerseDataKey)
        defaults.set(Date().timeIntervalSince1970, forKey: Self.randomVerseTimestampKey)
        defaults.set(translation, forKey: Self.randomVerseTranslationKey)
    }

    private func isRandomVerseFresh(now: Date = Date()) -> Bool {
        guard let defaults = sharedDefaults else {
            return false
        }

        let timestamp = defaults.double(forKey: Self.randomVerseTimestampKey)
        guard timestamp > 0 else {
            return false
        }

        let cachedDate = Date(timeIntervalSince1970: timestamp)
        return now.timeIntervalSince(cachedDate) < 60 * 60
    }
}

private struct RandomWidgetBibleResponse: Codable {
    let reference: String
    let text: String
    let translationName: String?
    let verses: [RandomWidgetVerseEntry]
}

private struct RandomWidgetVerseEntry: Codable {
    let bookName: String
    let chapter: Int
    let verse: Int
}
