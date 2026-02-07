//
//  AppTheme.swift
//  Bible App
//

import SwiftUI

/// Centralized design system constants for the Bible App
enum AppTheme {

    // MARK: - Colors

    static let accentGold = Color.accentGold
    static let cardBackground = Color.cardBackground
    static let primaryText = Color.primaryText
    static let secondaryText = Color.secondaryText
    static let dividerColor = Color.dividerColor

    // MARK: - Fonts

    /// Verse body text in serif font at the given size
    static func verseText(size: CGFloat = 20) -> Font {
        .system(size: size, design: .serif)
    }

    /// Reference label (e.g. "John 3:16")
    static let reference: Font = .body.weight(.semibold)

    /// Small translation badge label
    static let translationBadge: Font = .caption.weight(.medium)

    /// Section heading font
    static let heading: Font = .title2.bold()

    // MARK: - Spacing

    static let cardPadding: CGFloat = 24
    static let cardRadius: CGFloat = 20
    static let screenMargin: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let sectionGap: CGFloat = 32

    // MARK: - Card Shadow

    static let cardShadowColor: Color = .black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 12
    static let cardShadowY: CGFloat = 4
}
