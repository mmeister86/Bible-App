//
//  VerseCardView.swift
//  Bible App
//

import SwiftUI

/// A beautiful, reusable verse card component displaying a Bible verse
/// with reference, translation badge, and elegant typography.
/// Includes decorative quotation marks and a subtle divider.
struct VerseCardView: View {
    let response: BibleResponse

    @AppStorage("fontSize") private var fontSize: Double = 20.0
    @AppStorage("showVerseNumbers") private var showVerseNumbers: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Decorative Opening Quote
            Text("\u{201C}")
                .font(.system(size: fontSize * 2.5, design: .serif))
                .foregroundStyle(Color.accentGold.opacity(0.3))
                .lineLimit(1)
                .frame(height: fontSize * 1.5)
                .offset(x: -4)
                .accessibilityHidden(true)

            // MARK: - Verse Text
            verseTextContent
                .font(AppTheme.verseText(size: fontSize))
                .foregroundStyle(Color.primaryText)
                .lineSpacing(8)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Decorative closing quote (right-aligned)
            HStack {
                Spacer()
                Text("\u{201D}")
                    .font(.system(size: fontSize * 2.5, design: .serif))
                    .foregroundStyle(Color.accentGold.opacity(0.3))
                    .lineLimit(1)
                    .frame(height: fontSize * 1.2)
                    .offset(x: 4)
                    .accessibilityHidden(true)
            }

            // MARK: - Subtle Divider
            Rectangle()
                .fill(Color.dividerColor)
                .frame(height: 1)
                .padding(.vertical, 4)
                .accessibilityHidden(true)

            // MARK: - Reference & Translation
            VStack(alignment: .leading, spacing: 8) {
                Text(response.reference)
                    .font(AppTheme.reference)
                    .foregroundStyle(Color.secondaryText)

                translationBadge
            }
        }
        .padding(AppTheme.cardPadding)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(
            color: AppTheme.cardShadowColor,
            radius: AppTheme.cardShadowRadius,
            x: 0,
            y: AppTheme.cardShadowY
        )
    }

    // MARK: - Subviews

    /// Builds the verse text, optionally prepending inline verse numbers
    @ViewBuilder
    private var verseTextContent: some View {
        if showVerseNumbers && response.verses.count > 1 {
            Text(numberedVerseText)
        } else {
            Text(response.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    /// Concatenates verses with superscript-style verse numbers (gold-tinted, smaller)
    private var numberedVerseText: AttributedString {
        var result = AttributedString()

        for (index, verse) in response.verses.enumerated() {
            // Verse number — superscript style, gold-tinted
            var number = AttributedString("\(verse.verse) ")
            number.font = .system(size: fontSize * 0.55, weight: .bold, design: .serif)
            number.foregroundColor = Color.accentGold.opacity(0.8)
            number.baselineOffset = fontSize * 0.35

            // Verse text
            let cleanedText = verse.text.trimmingCharacters(in: .whitespacesAndNewlines)
            var text = AttributedString(cleanedText)
            text.font = .system(size: fontSize, design: .serif)

            result.append(number)
            result.append(text)

            // Add space between verses (but not after the last one)
            if index < response.verses.count - 1 {
                result.append(AttributedString(" "))
            }
        }

        return result
    }

    /// Small capsule badge showing the translation name
    private var translationBadge: some View {
        Text(response.translationName)
            .font(AppTheme.translationBadge)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.accentGold)
            )
    }
}

#Preview {
    VerseCardView(
        response: BibleResponse(
            reference: "John 3:16",
            verses: [
                VerseEntry(
                    bookId: "JHN",
                    bookName: "John",
                    chapter: 3,
                    verse: 16,
                    text: "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.\n"
                )
            ],
            text: "For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.\n",
            translationId: "web",
            translationName: "World English Bible",
            translationNote: "Public Domain"
        )
    )
    .padding(AppTheme.screenMargin)
}
