import SwiftUI
import WidgetKit
import AppIntents

struct RandomVerseEntry: TimelineEntry {
    let date: Date
    let verse: RandomVerseWidgetData
}

struct RandomVerseTimelineProvider: TimelineProvider {
    private let service = RandomVerseWidgetService()

    func placeholder(in context: Context) -> RandomVerseEntry {
        RandomVerseEntry(date: Date(), verse: service.placeholderVerse())
    }

    func getSnapshot(in context: Context, completion: @escaping (RandomVerseEntry) -> Void) {
        completion(RandomVerseEntry(date: Date(), verse: service.placeholderVerse()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RandomVerseEntry>) -> Void) {
        Task {
            let verse = await service.fetchRandomVerse()
            let entry = RandomVerseEntry(date: Date(), verse: verse)
            let timeline = Timeline(
                entries: [entry],
                policy: .after(service.nextRefreshDate())
            )
            completion(timeline)
        }
    }
}

struct RandomVerseWidgetView: View {
    var entry: RandomVerseTimelineProvider.Entry
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    private var currentTranslationId: String {
        let defaults = UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")
        return defaults?.string(forKey: "selectedTranslation") ?? "web"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Random Verse")
                .font(.caption.weight(.semibold))
                .foregroundStyle(widgetAccentGold)

            Text("\u{201C}\(entry.verse.text)\u{201D}")
                .font(fontSize)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            actionRow
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        switch family {
        case .systemSmall:
            Text(entry.verse.reference)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        case .systemMedium:
            HStack(spacing: 8) {
                Text(verseAttribution)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                favoriteButton
            }
        case .systemLarge:
            HStack(spacing: 16) {
                Text(verseAttribution)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer(minLength: 0)

                HStack(spacing: 12) {
                    favoriteButton
                    shareButton
                }
            }
        case .systemExtraLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline:
            Text(verseAttribution)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        @unknown default:
            Text(verseAttribution)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var favoriteButton: some View {
        Button(
            intent: ToggleFavoriteVerseIntent(
                reference: entry.verse.reference,
                text: entry.verse.text,
                bookName: entry.verse.bookName,
                chapter: entry.verse.chapter,
                verse: entry.verse.verse,
                translationName: entry.verse.translationName,
                translationId: currentTranslationId,
                sourceWidget: "randomVerse"
            )
        ) {
            Image(systemName: entry.verse.isFavorited ? "heart.fill" : "heart")
                .font(.body)
                .foregroundStyle(widgetAccentGold)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(entry.verse.isFavorited ? "Remove Favorite" : "Add Favorite")
    }

    private var shareButton: some View {
        Button(
            intent: ShareVerseIntent(
                reference: entry.verse.reference,
                text: entry.verse.text,
                bookName: entry.verse.bookName,
                chapter: entry.verse.chapter,
                verse: entry.verse.verse,
                translationName: entry.verse.translationName,
                translationId: currentTranslationId
            )
        ) {
            Image(systemName: "square.and.arrow.up")
                .font(.body)
                .foregroundStyle(widgetAccentGold)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Share Verse")
    }

    private var fontSize: Font {
        switch family {
        case .systemSmall:
            return .system(.footnote, design: .serif)
        case .systemMedium:
            return .system(.body, design: .serif)
        case .systemLarge:
            return .system(.body, design: .serif)
        case .systemExtraLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return .system(.body, design: .serif)
        @unknown default:
            return .system(.body, design: .serif)
        }
    }

    private var lineLimit: Int? {
        switch family {
        case .systemSmall:
            return 6
        case .systemMedium:
            return 5
        case .systemLarge:
            return 12
        case .systemExtraLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline:
            return 5
        @unknown default:
            return 5
        }
    }

    private var verseAttribution: String {
        guard family == .systemMedium || family == .systemLarge else {
            return entry.verse.reference
        }

        guard let source = entry.verse.source?.trimmingCharacters(in: .whitespacesAndNewlines), !source.isEmpty else {
            return entry.verse.reference
        }

        return "\(entry.verse.reference) \u{2022} \(source)"
    }

    private var widgetAccentGold: Color {
        switch colorScheme {
        case .dark:
            return Color(red: 226.0 / 255.0, green: 184.0 / 255.0, blue: 97.0 / 255.0)
        default:
            return Color(red: 201.0 / 255.0, green: 149.0 / 255.0, blue: 60.0 / 255.0)
        }
    }
}

struct RandomVerseWidget: Widget {
    let kind: String = "RandomVerseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomVerseTimelineProvider()) { entry in
            RandomVerseWidgetView(entry: entry)
        }
        .configurationDisplayName("Random Verse")
        .description("Shows a random Bible verse.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
