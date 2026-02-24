//
//  Bible_AppApp.swift
//  Bible App
//
//  Created by Matthias Meister on 0702.26.
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
    private static let appGroupID = "group.dev.matthiasmeister.Bible-App"
    private static let favoritesStoreFilename = "Favorites.sqlite"

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
        Self.migrateLegacyFavoritesStoreIfNeeded()

        let modelConfiguration: ModelConfiguration
        if let sharedStoreURL = Self.sharedFavoritesStoreURL() {
            modelConfiguration = ModelConfiguration(schema: schema, url: sharedStoreURL)
        } else {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // First fallback: try in-memory only
            print("Warning: Could not create persistent ModelContainer, attempting in-memory fallback: \(error)")
            
            do {
                let inMemoryConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                // Second fallback: this should never happen, but we fail gracefully
                print("CRITICAL: Could not create any ModelContainer: \(error)")
                
                // Return a minimal in-memory container - app may not persist favorites
                // but should still function
                fatalError("Unable to initialize data storage. Please reinstall the app.")
            }
        }
    }()

    private static func sharedFavoritesStoreURL() -> URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appending(path: favoritesStoreFilename)
    }

    private static func migrateLegacyFavoritesStoreIfNeeded() {
        guard let destinationURL = sharedFavoritesStoreURL() else {
            return
        }

        let fileManager = FileManager.default
        guard !fileManager.fileExists(atPath: destinationURL.path) else {
            return
        }

        guard let appSupportURL = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return
        }

        let legacyBaseURL = appSupportURL.appending(path: "default.store")
        let candidates = [
            (legacyBaseURL, destinationURL),
            (legacyBaseURL.appendingPathExtension("shm"), destinationURL.appendingPathExtension("shm")),
            (legacyBaseURL.appendingPathExtension("wal"), destinationURL.appendingPathExtension("wal")),
        ]

        guard fileManager.fileExists(atPath: legacyBaseURL.path) else {
            return
        }

        for (source, destination) in candidates where fileManager.fileExists(atPath: source.path) {
            try? fileManager.copyItem(at: source, to: destination)
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
