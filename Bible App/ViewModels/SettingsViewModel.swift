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

    var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                NotificationService.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            } else {
                NotificationService.cancelDailyReminder()
            }
        }
    }

    var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminderHour")
            if notificationsEnabled {
                NotificationService.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            }
        }
    }

    var reminderMinute: Int {
        didSet {
            UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute")
            if notificationsEnabled {
                NotificationService.scheduleDailyReminder(hour: reminderHour, minute: reminderMinute)
            }
        }
    }

    /// Tracks whether the system denied notification permission.
    var notificationPermissionDenied: Bool = false

    /// Computed Date for the time picker, derived from reminderHour and reminderMinute.
    var reminderTime: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 8
            reminderMinute = components.minute ?? 0
        }
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

        // Notifications: defaults to disabled, 8:00 AM
        self.notificationsEnabled = defaults.bool(forKey: "notificationsEnabled")

        if defaults.object(forKey: "reminderHour") != nil {
            self.reminderHour = defaults.integer(forKey: "reminderHour")
        } else {
            self.reminderHour = 8
        }

        if defaults.object(forKey: "reminderMinute") != nil {
            self.reminderMinute = defaults.integer(forKey: "reminderMinute")
        } else {
            self.reminderMinute = 0
        }
    }

    // MARK: - Actions

    /// Commit font size to persistent storage (call on slider release, not during drag).
    func commitFontSize(_ size: Double) {
        fontSize = size
    }

    /// Called when the user toggles notifications ON.
    /// Requests permission just-in-time and handles denial.
    func enableNotifications() async {
        let status = await NotificationService.authorizationStatus()

        switch status {
        case .notDetermined:
            let granted = await NotificationService.requestAuthorization()
            if granted {
                notificationsEnabled = true
                notificationPermissionDenied = false
            } else {
                notificationsEnabled = false
                notificationPermissionDenied = true
            }
        case .authorized, .provisional, .ephemeral:
            notificationsEnabled = true
            notificationPermissionDenied = false
        case .denied:
            notificationsEnabled = false
            notificationPermissionDenied = true
        @unknown default:
            notificationsEnabled = false
        }
    }

    /// Called when the user disables notifications.
    func disableNotifications() {
        notificationsEnabled = false
        notificationPermissionDenied = false
    }

    /// Reset all settings to their default values.
    func resetToDefaults() {
        appearanceMode = 0
        selectedTranslation = "web"
        fontSize = 20.0
        showVerseNumbers = true
        notificationsEnabled = false
        reminderHour = 8
        reminderMinute = 0
        notificationPermissionDenied = false
    }
}
