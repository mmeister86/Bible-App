import AppIntents
import OSLog

struct ShareVerseIntent: AppIntent {
    static var title: LocalizedStringResource = "Share Verse"
    static var description = IntentDescription("Opens the share sheet for the current verse.")
    static var openAppWhenRun: Bool = true
    
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetShareIntent")

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
        logger.debug("Share intent triggered for \(self.reference, privacy: .public)")
        
        let defaults = UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")
        
        let verseData: [String: Any] = [
            "reference": reference,
            "text": text,
            "bookName": bookName,
            "chapter": chapter,
            "verse": verse,
            "translationName": translationName,
            "translationId": translationId
        ]
        
        defaults?.set(verseData, forKey: "pendingShareVerse")
        logger.debug("pendingShareVerse saved to app group defaults")
        
        return .result()
    }
}

@available(iOS 26.0, *)
extension ShareVerseIntent {
    static var supportedModes: IntentModes { .foreground }
}
