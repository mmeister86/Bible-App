//
//  SettingsViewModel.swift
//  Bible App
//

import Foundation

/// Drives the settings screen. All properties are synced with UserDefaults
/// so they persist across launches and are readable via @AppStorage elsewhere.
@Observable
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

    var selectedTranslation: String {
        didSet { UserDefaults.standard.set(selectedTranslation, forKey: "selectedTranslation") }
    }

    var appearanceMode: String {
        didSet { UserDefaults.standard.set(appearanceMode, forKey: "appearanceMode") }
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

        self.selectedTranslation = defaults.string(forKey: "selectedTranslation") ?? "web"
        self.appearanceMode = defaults.string(forKey: "appearanceMode") ?? "system"

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

    /// Reset all settings to their default values.
    func resetToDefaults() {
        selectedTranslation = "web"
        appearanceMode = "system"
        fontSize = 20.0
        showVerseNumbers = true
    }
}
