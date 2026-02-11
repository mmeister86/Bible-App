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

    @AppStorage("fontSize") private var userFontSize: Double = 20.0
    @AppStorage("showVerseNumbers") private var showVerseNumbers: Bool = true
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    /// Calculated font size combining user preference with Dynamic Type
    private var fontSize: CGFloat {
        let baseSize = userFontSize
        // Scale with Dynamic Type (xSmall to accessibilityLarge)
        let scale: CGFloat
        switch dynamicTypeSize {
        case .xSmall: scale = 0.8
        case .small: scale = 0.85
        case .medium: scale = 0.9
        case .large: scale = 1.0
        case .xLarge: scale = 1.1
        case .xxLarge: scale = 1.2
        case .xxxLarge: scale = 1.35
        case .accessibility1: scale = 1.5
        case .accessibility2: scale = 1.65
        case .accessibility3: scale = 1.8
        case .accessibility4: scale = 2.0
        case .accessibility5: scale = 2.2
        default: scale = 1.0
        }
        return baseSize * scale
    }

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
                .font(.system(size: fontSize, design: .serif))
                .foregroundStyle(Color.primaryText)
                .lineSpacing(fontSize * 0.4)
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
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
    
    /// Combined accessibility label for VoiceOver
    private var accessibilityLabel: String {
        let text = response.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return "\(response.reference), \(text), \(response.translationName) translation"
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
            .accessibilityLabel("Translation: \(response.translationName)")
    }
}

#Preview {
    VStack(spacing: 20) {
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
        
        VerseCardView(
            response: BibleResponse(
                reference: "Psalm 23:1-3",
                verses: [
                    VerseEntry(
                        bookId: "PSA",
                        bookName: "Psalm",
                        chapter: 23,
                        verse: 1,
                        text: "The LORD is my shepherd; I shall not want."
                    ),
                    VerseEntry(
                        bookId: "PSA",
                        bookName: "Psalm",
                        chapter: 23,
                        verse: 2,
                        text: "He maketh me to lie down in green pastures: he leadeth me beside the still waters."
                    ),
                    VerseEntry(
                        bookId: "PSA",
                        bookName: "Psalm",
                        chapter: 23,
                        verse: 3,
                        text: "He restoreth my soul: he leadeth me in the paths of righteousness for his name's sake."
                    )
                ],
                text: "The LORD is my shepherd; I shall not want. He maketh me to lie down in green pastures: he leadeth me beside the still waters. He restoreth my soul.",
                translationId: "kjv",
                translationName: "King James Version",
                translationNote: "Public Domain"
            )
        )
    }
    .padding(AppTheme.screenMargin)
}
