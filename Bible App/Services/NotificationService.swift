//
//  NotificationService.swift
//  Bible App
//

import UserNotifications

/// Manages daily verse reminder notifications.
/// Stateless service — all methods are static, matching the project's Services pattern.
struct NotificationService {

    // MARK: - Constants

    private static let dailyReminderIdentifier = "daily-verse-reminder"

    // MARK: - Permission

    /// Requests notification authorization. Returns `true` if granted.
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    /// Returns the current authorization status.
    static func authorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // MARK: - Scheduling

    /// Schedules (or reschedules) the daily verse reminder at the given hour and minute.
    /// Removes any existing pending request first so there is always exactly one.
    static func scheduleDailyReminder(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        center.removePendingNotificationRequests(
            withIdentifiers: [dailyReminderIdentifier]
        )

        let content = UNMutableNotificationContent()
        content.title = "Your Daily Bible Verse"
        content.body = "A new verse is waiting for you. Open the app and get inspired."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }

    /// Cancels the daily verse reminder.
    static func cancelDailyReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [dailyReminderIdentifier]
            )
    }
}
