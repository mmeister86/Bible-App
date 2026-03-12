//
//  WatchAppTheme.swift
//  DailyVerse WatchApp Watch App
//

import SwiftUI

enum WatchAppTheme {
    enum Colors {
        static func accentGold(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#E2B861") : Color(hex: "#C9953C")
        }

        static func cardBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#1C1C1E") : Color(hex: "#FFFDF7")
        }

        static func primaryText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#F5F5F5") : Color(hex: "#1A1A1A")
        }

        static func secondaryText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#A0A0A0") : Color(hex: "#6B6B6B")
        }

        static func divider(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#3A3A3C") : Color(hex: "#E0DDD5")
        }

        static func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(hex: "#101012"), Color(hex: "#050506")]
                    : [Color(hex: "#FFF7E8"), Color(hex: "#F4F0E6")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        static func statusInfo(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#86B8E6") : Color(hex: "#446682")
        }

        static func statusWarning(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#F2C26B") : Color(hex: "#9B6A1A")
        }

        static func statusError(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? Color(hex: "#F38A80") : Color(hex: "#A13A32")
        }
    }

    enum Typography {
        static let title: Font = .system(size: 18, weight: .bold, design: .rounded)
        static let cardVerse: Font = .system(size: 16, weight: .regular, design: .serif)
        static let cardReference: Font = .system(size: 13, weight: .semibold, design: .rounded)
        static let cardTranslation: Font = .system(size: 10, weight: .medium, design: .rounded)
        static let status: Font = .system(size: 11, weight: .medium, design: .rounded)
        static let button: Font = .system(size: 13, weight: .semibold, design: .rounded)
    }

    enum Metrics {
        static let horizontalPadding: CGFloat = 10
        static let sectionSpacing: CGFloat = 10
        static let cardPadding: CGFloat = 12
        static let cardCornerRadius: CGFloat = 14
        static let statusCornerRadius: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 36
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
