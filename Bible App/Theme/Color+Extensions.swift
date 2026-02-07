//
//  Color+Extensions.swift
//  Bible App
//

import SwiftUI

extension Color {
    /// Initialize a Color from a hex string (e.g. "#C9953C" or "C9953C")
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    // MARK: - App Colors (Light / Dark)

    /// Warm gold accent — Light: #C9953C, Dark: #E2B861
    static let accentGold = Color(
        light: Color(hex: "#C9953C"),
        dark: Color(hex: "#E2B861")
    )

    /// Card background — Light: #FFFDF7, Dark: #1C1C1E
    static let cardBackground = Color(
        light: Color(hex: "#FFFDF7"),
        dark: Color(hex: "#1C1C1E")
    )

    /// Primary text — Light: #1A1A1A, Dark: #F5F5F5
    static let primaryText = Color(
        light: Color(hex: "#1A1A1A"),
        dark: Color(hex: "#F5F5F5")
    )

    /// Secondary text — Light: #6B6B6B, Dark: #A0A0A0
    static let secondaryText = Color(
        light: Color(hex: "#6B6B6B"),
        dark: Color(hex: "#A0A0A0")
    )

    /// Divider/separator — Light: #E0DDD5, Dark: #3A3A3C
    static let dividerColor = Color(
        light: Color(hex: "#E0DDD5"),
        dark: Color(hex: "#3A3A3C")
    )
}

// MARK: - Light/Dark Mode Helper

private extension Color {
    /// Creates a dynamic color that adapts to the current color scheme
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
