//
//  WatchVerseCardView.swift
//  DailyVerse WatchApp Watch App
//

import SwiftUI

struct WatchVerseCardView: View {
    let verse: BibleResponse
    let selectedTranslation: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(WatchAppTheme.Typography.cardVerse)
                .foregroundStyle(WatchAppTheme.Colors.primaryText(for: colorScheme))

            Divider()
                .overlay(WatchAppTheme.Colors.divider(for: colorScheme))

            HStack(alignment: .center, spacing: 8) {
                Text(verse.reference)
                    .font(WatchAppTheme.Typography.cardReference)
                    .foregroundStyle(WatchAppTheme.Colors.accentGold(for: colorScheme))

                Spacer(minLength: 0)

                Text(selectedTranslation.uppercased())
                    .font(WatchAppTheme.Typography.cardTranslation)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule(style: .continuous)
                            .fill(WatchAppTheme.Colors.accentGold(for: colorScheme).opacity(0.2))
                    )
                    .foregroundStyle(WatchAppTheme.Colors.accentGold(for: colorScheme))
            }
        }
        .padding(WatchAppTheme.Metrics.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: WatchAppTheme.Metrics.cardCornerRadius, style: .continuous)
                .fill(WatchAppTheme.Colors.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: WatchAppTheme.Metrics.cardCornerRadius, style: .continuous)
                .stroke(WatchAppTheme.Colors.divider(for: colorScheme).opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    WatchVerseCardView(
        verse: BibleResponse(
            reference: "Psalm 23:1",
            verses: [],
            text: "Der HERR ist mein Hirte, mir wird nichts mangeln.",
            translationId: "web",
            translationName: "World English Bible",
            translationNote: ""
        ),
        selectedTranslation: "web"
    )
    .padding()
}
