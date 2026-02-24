import SwiftUI
import WidgetKit

struct DailyVerseEntry: TimelineEntry {
    let date: Date
    let verse: DailyVerseWidgetData
}

struct DailyVerseTimelineProvider: TimelineProvider {
    private let service = DailyVerseWidgetService()

    func placeholder(in context: Context) -> DailyVerseEntry {
        DailyVerseEntry(date: Date(), verse: service.placeholderVerse())
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyVerseEntry) -> Void) {
        completion(DailyVerseEntry(date: Date(), verse: service.placeholderVerse()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyVerseEntry>) -> Void) {
        Task {
            let verse = await service.fetchDailyVerse()
            let entry = DailyVerseEntry(date: Date(), verse: verse)
            let timeline = Timeline(
                entries: [entry],
                policy: .after(service.nextRefreshDate())
            )
            completion(timeline)
        }
    }
}

struct DailyVerseWidgetView: View {
    var entry: DailyVerseTimelineProvider.Entry
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    /// Get current translation ID from shared UserDefaults
    private var currentTranslationId: String {
        let defaults = UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")
        return defaults?.string(forKey: "selectedTranslation") ?? "web"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verse of the Day")
                .font(.caption.weight(.semibold))
                .foregroundStyle(widgetAccentGold)

            Text("\u{201C}\(entry.verse.text)\u{201D}")
                .font(family == .systemSmall ? .system(.footnote, design: .serif) : .system(.body, design: .serif))
                .lineLimit(family == .systemSmall ? 6 : 5)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            if family == .systemMedium {
                HStack(spacing: 8) {
                    Text(verseAttribution)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    Button(
                        intent: ToggleFavoriteVerseIntent(
                            reference: entry.verse.reference,
                            text: entry.verse.text,
                            bookName: entry.verse.bookName,
                            chapter: entry.verse.chapter,
                            verse: entry.verse.verse,
                            translationName: entry.verse.translationName,
                            translationId: currentTranslationId
                        )
                    ) {
                        Image(systemName: entry.verse.isFavorited ? "heart.fill" : "heart")
                            .font(.body)
                            .foregroundStyle(widgetAccentGold)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(entry.verse.isFavorited ? "Remove Favorite" : "Add Favorite")
                }
            } else {
                Text(verseAttribution)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    private var verseAttribution: String {
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

@main
struct VerseOfTheDayWidget: Widget {
    let kind: String = "VerseOfTheDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyVerseTimelineProvider()) { entry in
            DailyVerseWidgetView(entry: entry)
        }
        .configurationDisplayName("Verse of the Day")
        .description("Shows today's Bible verse in English.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
