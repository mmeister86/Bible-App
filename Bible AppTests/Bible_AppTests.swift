//
//  Bible_AppTests.swift
//  Bible AppTests
//
//  Created by Matthias Meister on 07.02.26.
//

import Testing
import Foundation
@testable import Bible_App

struct Bible_AppTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}

// MARK: - Notification Settings Tests

@Suite(.serialized) struct NotificationSettingsTests {

    private static let appGroupDefaults = UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")
    private let defaults = UserDefaults.standard

    init() {
        Self.resetDefaults()
    }

    static func resetDefaults() {
        let keys = [
            "appearanceMode",
            "selectedTranslation",
            "fontSize",
            "showVerseNumbers",
            "notificationsEnabled",
            "reminderHour",
            "reminderMinute"
        ]

        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
            appGroupDefaults?.removeObject(forKey: key)
        }
    }

    @Test @MainActor func defaultReminderTimeIs8AM() {
        defaults.removeObject(forKey: "reminderHour")
        defaults.removeObject(forKey: "reminderMinute")

        let vm = SettingsViewModel()
        #expect(vm.reminderHour == 8)
        #expect(vm.reminderMinute == 0)
    }

    @Test @MainActor func notificationsDefaultToDisabled() {
        defaults.removeObject(forKey: "notificationsEnabled")

        let vm = SettingsViewModel()
        #expect(vm.notificationsEnabled == false)
    }

    @Test @MainActor func togglePersistsToUserDefaults() {
        let vm = SettingsViewModel()
        vm.notificationsEnabled = true
        #expect(UserDefaults.standard.bool(forKey: "notificationsEnabled") == true)

        vm.notificationsEnabled = false
        #expect(UserDefaults.standard.bool(forKey: "notificationsEnabled") == false)
    }

    @Test @MainActor func reminderTimePersistsToUserDefaults() {
        let vm = SettingsViewModel()
        vm.reminderHour = 19
        vm.reminderMinute = 30

        #expect(UserDefaults.standard.integer(forKey: "reminderHour") == 19)
        #expect(UserDefaults.standard.integer(forKey: "reminderMinute") == 30)
    }

    @Test @MainActor func resetToDefaultsClearsNotificationSettings() {
        let vm = SettingsViewModel()
        vm.notificationsEnabled = true
        vm.reminderHour = 22
        vm.reminderMinute = 45

        vm.resetToDefaults()

        #expect(vm.notificationsEnabled == false)
        #expect(vm.reminderHour == 8)
        #expect(vm.reminderMinute == 0)
    }

    @Test @MainActor func reminderTimeComputedPropertyRoundTrips() {
        let vm = SettingsViewModel()
        vm.reminderHour = 14
        vm.reminderMinute = 30

        let time = vm.reminderTime
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        #expect(components.hour == 14)
        #expect(components.minute == 30)
    }

    @Test @MainActor func settingReminderTimeUpdatesHourAndMinute() {
        let vm = SettingsViewModel()

        var components = DateComponents()
        components.hour = 17
        components.minute = 45
        if let date = Calendar.current.date(from: components) {
            vm.reminderTime = date
        }

        #expect(vm.reminderHour == 17)
        #expect(vm.reminderMinute == 45)
    }

    @Test @MainActor func fontSizeDefaultsTo20WhenUnset() {
        defaults.removeObject(forKey: "fontSize")

        let vm = SettingsViewModel()
        #expect(vm.fontSize == 20.0)
    }

    @Test @MainActor func commitFontSizePersistsToUserDefaults() {
        let vm = SettingsViewModel()

        vm.commitFontSize(24.0)

        #expect(vm.fontSize == 24.0)
        #expect(defaults.double(forKey: "fontSize") == 24.0)
    }

    @Test @MainActor func showVerseNumbersDefaultsToTrueWhenUnset() {
        defaults.removeObject(forKey: "showVerseNumbers")

        let vm = SettingsViewModel()
        #expect(vm.showVerseNumbers == true)
    }

    @Test @MainActor func showVerseNumbersPersistsToUserDefaults() {
        let vm = SettingsViewModel()

        vm.showVerseNumbers = false

        #expect(defaults.bool(forKey: "showVerseNumbers") == false)
    }

    @Test @MainActor func appearanceModePersistsToUserDefaults() {
        let vm = SettingsViewModel()

        vm.appearanceMode = 2

        #expect(defaults.integer(forKey: "appearanceMode") == 2)
    }

    @Test @MainActor func selectedTranslationUsesStoredValueOnInit() {
        defaults.set("bbe", forKey: "selectedTranslation")

        let vm = SettingsViewModel()

        #expect(vm.selectedTranslation == "bbe")
    }

    @Test @MainActor func resetToDefaultsRestoresAppearanceAndReadingPreferences() {
        let vm = SettingsViewModel()
        vm.appearanceMode = 2
        vm.fontSize = 28.0
        vm.showVerseNumbers = false

        vm.resetToDefaults()

        #expect(vm.appearanceMode == 0)
        #expect(vm.fontSize == 20.0)
        #expect(vm.showVerseNumbers == true)
    }
}
