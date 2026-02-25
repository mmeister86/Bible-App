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

    @Parameter(title: "Source Widget")
    var sourceWidget: String

    init() {}

    init(
        reference: String,
        text: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        translationName: String,
        translationId: String,
        sourceWidget: String
    ) {
        self.reference = reference
        self.text = text
        self.bookName = bookName
        self.chapter = chapter
        self.verse = verse
        self.translationName = translationName
        self.translationId = translationId
        self.sourceWidget = sourceWidget
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

        // Only update the daily verse cache when the toggle originates from the daily verse widget.
        // This prevents the random verse from overwriting the verse of the day.
        if sourceWidget == "dailyVerse" {
            DailyVerseWidgetService.cacheVerseForToday(
                reference: reference,
                text: text,
                bookName: bookName,
                chapter: chapter,
                verse: verse,
                translationName: translationName,
                translationId: translationId
            )
        }

        logger.debug(
            "Toggled favorite for \(reference, privacy: .public). isNowFavorited=\(isNowFavorited, privacy: .public) source=\(sourceWidget, privacy: .public)"
        )

        WidgetCenter.shared.reloadTimelines(ofKind: "VerseOfTheDayWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "RandomVerseWidget")
        return .result()
    }
}
