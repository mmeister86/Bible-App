import AppIntents
import OSLog
import WidgetKit

struct ToggleFavoriteVerseIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Favorite Verse"
    static var description = IntentDescription("Adds or removes the current verse from favorites.")
    static var openAppWhenRun: Bool = false
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetFavoriteIntent")

    @Parameter(title: "Reference")
    var reference: String

    @Parameter(title: "Text")
    var text: String

    @Parameter(title: "Book Name")
    var bookName: String

    @Parameter(title: "Chapter")
    var chapter: Int

    @Parameter(title: "Verse")
    var verse: Int

    @Parameter(title: "Translation Name")
    var translationName: String

    @Parameter(title: "Translation ID")
    var translationId: String

    init() {}

    init(
        reference: String,
        text: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        translationName: String,
        translationId: String
    ) {
        self.reference = reference
        self.text = text
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.translationName = translationName
        self.translationId = translationId
    }

    func perform() async throws -> some IntentResult {
        let store = WidgetFavoritesStore()
        let isNowFavorited = try store.toggleFavorite(
            reference: reference,
            text: text,
            bookName: bookName,
            chapter: chapter,
            verse: verse,
            translationName: translationName
        )

        // Update the cached verse with current favorite status
        // This ensures the widget shows the correct favorite state
        DailyVerseWidgetService.cacheVerseForToday(
            reference: reference,
            text: text,
            bookName: bookName,
            chapter: chapter,
            verse: verse,
            translationName: translationName,
            translationId: translationId
        )

        logger.debug(
            "Toggled favorite for \(reference, privacy: .public). isNowFavorited=\(isNowFavorited, privacy: .public)"
        )

        WidgetCenter.shared.reloadTimelines(ofKind: "VerseOfTheDayWidget")
        return .result()
    }
}
