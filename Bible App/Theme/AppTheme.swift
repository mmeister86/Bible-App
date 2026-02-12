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
    
    /// Caption font
    static let caption: Font = .caption

    // MARK: - Spacing

    static let cardPadding: CGFloat = 24
    static let cardRadius: CGFloat = 20
    static let screenMargin: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let sectionGap: CGFloat = 32
    
    /// Minimum touch target size (Apple HIG recommendation)
    static let minTouchTarget: CGFloat = 44

    // MARK: - Card Shadow

    static let cardShadowColor: Color = .black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 12
    static let cardShadowY: CGFloat = 4
    
    // MARK: - Background Gradient
    
    /// Creates the standard background gradient that adapts to color scheme
    static func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(hex: "#1C1C1E"), Color(.systemBackground)]
                : [Color.cardBackground.opacity(0.5), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Animation
    
    /// Standard spring animation for card appearances
    static let cardAppearAnimation: Animation = .spring(response: 0.5, dampingFraction: 0.8)
    
    /// Quick spring animation for button interactions
    static let buttonSpringAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.6)
    
    /// Standard fade animation
    static let fadeAnimation: Animation = .easeInOut(duration: 0.25)
    
    // MARK: - View Modifiers
    
    /// Standard card style modifier
    static func cardStyle() -> some View {
        RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
            .fill(Color.cardBackground)
            .shadow(
                color: AppTheme.cardShadowColor,
                radius: AppTheme.cardShadowRadius,
                x: 0,
                y: AppTheme.cardShadowY
            )
    }
}

// MARK: - Color Scheme Extension

extension ColorScheme {
    /// Returns the appropriate background gradient for this color scheme
    var backgroundGradient: LinearGradient {
        AppTheme.backgroundGradient(for: self)
    }
}

// MARK: - View Extension for Background

extension View {
    /// Applies the standard background gradient for the current color scheme
    func themedBackground(colorScheme: ColorScheme) -> some View {
        ZStack {
            AppTheme.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()
            self
        }
    }
}
