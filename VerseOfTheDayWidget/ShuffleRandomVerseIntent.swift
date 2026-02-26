import AppIntents
import OSLog
import WidgetKit

struct ShuffleRandomVerseIntent: AppIntent {
    static var title: LocalizedStringResource = "Shuffle Random Verse"
    static var description = IntentDescription("Fetches a new random verse for the Random Verse widget.")
    static var openAppWhenRun: Bool = false

    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetShuffleIntent")

    func perform() async throws -> some IntentResult {
        let service = RandomVerseWidgetService()
        let refreshedVerse = await service.fetchRandomVerse(forceRefresh: true)

        logger.debug("Shuffled random widget verse to \(refreshedVerse.reference, privacy: .public)")

        WidgetCenter.shared.reloadTimelines(ofKind: "RandomVerseWidget")
        return .result()
    }
}
