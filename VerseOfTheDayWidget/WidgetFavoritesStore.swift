import Foundation
import SwiftData
import OSLog

struct WidgetFavoritesStore {
    private let appGroupID = "group.dev.matthiasmeister.Bible-App"
    private let storeFilename = "Favorites.sqlite"
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WidgetFavoritesStore")

    func isFavorited(reference: String) -> Bool {
        guard let container = try? makeContainer() else {
            return false
        }

        let context = ModelContext(container)
        var descriptor = FetchDescriptor<FavoriteVerse>(
            predicate: #Predicate { favorite in
                favorite.reference == reference
            }
        )
        descriptor.fetchLimit = 1

        return (try? context.fetchCount(descriptor)) ?? 0 > 0
    }

    @discardableResult
    func toggleFavorite(
        reference: String,
        text: String,
        bookName: String,
        chapter: Int,
        verse: Int,
        translationName: String
    ) throws -> Bool {
        let container = try makeContainer()
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<FavoriteVerse>(
            predicate: #Predicate { favorite in
                favorite.reference == reference
            }
        )
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            context.delete(existing)
            try context.save()
            return false
        }

        let favorite = FavoriteVerse(
            reference: reference,
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            bookName: bookName,
            chapter: chapter,
            verse: verse,
            translationName: translationName
        )
        context.insert(favorite)
        try context.save()
        return true
    }

    private func makeContainer() throws -> ModelContainer {
        logger.debug("Using FavoriteVerse model type: \(String(reflecting: FavoriteVerse.self), privacy: .public)")
        let schema = Schema([FavoriteVerse.self])
        let url = try storeURL()
        logger.debug("Using favorites store at \(url.path(percentEncoded: false), privacy: .public)")
        let configuration = ModelConfiguration(schema: schema, url: url)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func storeURL() throws -> URL {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            throw CocoaError(.fileNoSuchFile)
        }

        return groupURL.appending(path: storeFilename)
    }
}
