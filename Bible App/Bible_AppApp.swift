//
//  Bible_AppApp.swift
//  Bible App
//
//  Created by Matthias Meister on 07.02.26.
//

import SwiftUI
import SwiftData
import UserNotifications

extension Notification.Name {
    /// Posted when the user taps the daily verse notification.
    static let didTapDailyVerseNotification = Notification.Name("didTapDailyVerseNotification")
}

/// Handles notification presentation and user interaction with notifications.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    /// Suppresses notification banners when the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return []
    }

    /// Called when the user taps a delivered notification.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run {
            NotificationCenter.default.post(name: .didTapDailyVerseNotification, object: nil)
        }
    }
}

@main
struct Bible_AppApp: App {
    @AppStorage("appearanceMode") private var appearanceMode: Int = 0

    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate

        // Reschedule daily reminder if notifications were previously enabled
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "notificationsEnabled") {
            let hour = defaults.object(forKey: "reminderHour") != nil
                ? defaults.integer(forKey: "reminderHour")
                : 8
            let minute = defaults.object(forKey: "reminderMinute") != nil
                ? defaults.integer(forKey: "reminderMinute")
                : 0
            NotificationService.scheduleDailyReminder(hour: hour, minute: minute)
        }
    }

    private var preferredColorScheme: ColorScheme? {
        AppearanceMode(rawValue: appearanceMode)?.colorScheme
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteVerse.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Fallback to in-memory container for graceful degradation
            print("Warning: Could not create persistent ModelContainer, falling back to in-memory: \(error)")
            return try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
