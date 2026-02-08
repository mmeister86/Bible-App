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

struct NotificationSettingsTests {

    @Test @MainActor func defaultReminderTimeIs8AM() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "reminderHour")
        defaults.removeObject(forKey: "reminderMinute")

        let vm = SettingsViewModel()
        #expect(vm.reminderHour == 8)
        #expect(vm.reminderMinute == 0)
    }

    @Test @MainActor func notificationsDefaultToDisabled() {
        let defaults = UserDefaults.standard
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
}
