//
//  SearchResultView.swift
//  Bible App
//

import SwiftUI

/// A compact row view for displaying a search result.
/// Can be used in lists or as an alternative to the full VerseCardView.
struct SearchResultView: View {
    let response: BibleResponse

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Reference
            Text(response.reference)
                .font(AppTheme.reference)
                .foregroundStyle(Color.primaryText)

            // Verse text preview (truncated)
            Text(response.text.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.body)
                .foregroundStyle(Color.secondaryText)
                .lineLimit(3)
                .lineSpacing(4)

            // Translation badge
            Text(response.translationName)
                .font(AppTheme.translationBadge)
                .foregroundStyle(Color.accentGold)
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(
            color: AppTheme.cardShadowColor,
            radius: AppTheme.cardShadowRadius / 2,
            x: 0,
            y: AppTheme.cardShadowY / 2
        )
    }
}

#Preview {
    SearchResultView(
        response: BibleResponse(
            reference: "Romans 8:28",
            verses: [
                VerseEntry(
                    bookId: "ROM",
                    bookName: "Romans",
                    chapter: 8,
                    verse: 28,
                    text: "We know that all things work together for good for those who love God, for those who are called according to his purpose.\n"
                )
            ],
            text: "We know that all things work together for good for those who love God, for those who are called according to his purpose.\n",
            translationId: "web",
            translationName: "World English Bible",
            translationNote: "Public Domain"
        )
    )
    .padding(AppTheme.screenMargin)
}
