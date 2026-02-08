//
//  SettingsViewModel.swift
//  Bible App
//

import Foundation
import SwiftUI

/// Appearance mode for the app (System, Light, Dark).
enum AppearanceMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var label: String {
        switch self {
        case .system: "System"
        case .light: "Hell"
        case .dark: "Dunkel"
        }
    }
}

/// Drives the settings screen. All properties are synced with UserDefaults
/// so they persist across launches and are readable via @AppStorage elsewhere.
@MainActor @Observable
final class SettingsViewModel {

    // MARK: - Translation Model

    struct Translation: Identifiable {
        let id: String
        let name: String
    }

    static let availableTranslations: [Translation] = [
        .init(id: "web", name: "World English Bible"),
        .init(id: "kjv", name: "King James Version"),
        .init(id: "bbe", name: "Bible in Basic English"),
        .init(id: "oeb-us", name: "Open English Bible, US Ed."),
    ]

    // MARK: - Settings Properties

    var appearanceMode: Int {
        didSet { UserDefaults.standard.set(appearanceMode, forKey: "appearanceMode") }
    }

    var selectedTranslation: String {
        didSet { UserDefaults.standard.set(selectedTranslation, forKey: "selectedTranslation") }
    }

    var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "fontSize") }
    }

    var showVerseNumbers: Bool {
        didSet { UserDefaults.standard.set(showVerseNumbers, forKey: "showVerseNumbers") }
    }

    // MARK: - Init

    init() {
        let defaults = UserDefaults.standard

        self.appearanceMode = defaults.integer(forKey: "appearanceMode")
        self.selectedTranslation = defaults.string(forKey: "selectedTranslation") ?? "web"

        // fontSize: UserDefaults returns 0.0 for unset keys, so default to 20
        let storedFontSize = defaults.double(forKey: "fontSize")
        self.fontSize = storedFontSize > 0 ? storedFontSize : 20.0

        // showVerseNumbers: defaults to true if not yet set
        if defaults.object(forKey: "showVerseNumbers") != nil {
            self.showVerseNumbers = defaults.bool(forKey: "showVerseNumbers")
        } else {
            self.showVerseNumbers = true
        }
    }

    // MARK: - Actions

    /// Commit font size to persistent storage (call on slider release, not during drag).
    func commitFontSize(_ size: Double) {
        fontSize = size
    }

    /// Reset all settings to their default values.
    func resetToDefaults() {
        appearanceMode = 0
        selectedTranslation = "web"
        fontSize = 20.0
        showVerseNumbers = true
    }
}
