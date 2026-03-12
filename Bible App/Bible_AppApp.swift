//
//  Bible_AppApp.swift
//  Bible App
//
//  Created by Matthias Meister on 0702.26.
//

import SwiftUI
import SwiftData
import Combine
import UserNotifications
import OSLog
#if canImport(UIKit)
import UIKit
#endif

extension Notification.Name {
    static let didTapDailyVerseNotification = Notification.Name("didTapDailyVerseNotification")
    static let didTriggerShare = Notification.Name("didTriggerShare")
}

enum QuickActionDestination {
    case today
    case discover
    case search
    case favorites
}

#if canImport(UIKit)
typealias PlatformShortcutItem = UIApplicationShortcutItem
#else
struct PlatformShortcutItem {
    let type: String
}
#endif

enum QuickActionType: String {
    case today = "dev.matthiasmeister.Bible-App.quickaction.today"
    case discover = "dev.matthiasmeister.Bible-App.quickaction.discover"
    case search = "dev.matthiasmeister.Bible-App.quickaction.search"
    case favorites = "dev.matthiasmeister.Bible-App.quickaction.favorites"

    var destination: QuickActionDestination {
        switch self {
        case .today: return .today
        case .discover: return .discover
        case .search: return .search
        case .favorites: return .favorites
        }
    }
}

@MainActor
final class QuickActionCenter: ObservableObject {
    static let shared = QuickActionCenter()

    @Published private(set) var requestedDestination: QuickActionDestination?

    private var pendingDestination: QuickActionDestination?
    private var isInterfaceReady = false

    private init() {}

    func handleShortcutItem(_ shortcutItem: PlatformShortcutItem) -> Bool {
        guard let actionType = QuickActionType(rawValue: shortcutItem.type) else {
            return false
        }

        route(to: actionType.destination)
        return true
    }

    func markInterfaceReadyAndConsumePendingDestination() -> QuickActionDestination? {
        isInterfaceReady = true

        guard let pendingDestination else {
            return nil
        }

        self.pendingDestination = nil
        return pendingDestination
    }

    func consumeInitialDestination(fallback: QuickActionDestination = .today) -> QuickActionDestination {
        markInterfaceReadyAndConsumePendingDestination() ?? fallback
    }

    func consumeCurrentRequest() {
        requestedDestination = nil
    }

    private func route(to destination: QuickActionDestination) {
        if isInterfaceReady {
            requestedDestination = destination
        } else {
            pendingDestination = destination
        }
    }
}

#if canImport(UIKit)
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

@MainActor
final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let shortcutItem = connectionOptions.shortcutItem else {
            return
        }

        _ = QuickActionCenter.shared.handleShortcutItem(shortcutItem)
    }

    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = QuickActionCenter.shared.handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }
}
#endif

struct PendingShareData: Equatable {
    let reference: String
    let text: String
    let bookName: String
    let chapter: Int
    let verse: Int
    let translationName: String
    let translationId: String
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return []
    }

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
#if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
#endif
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "AppShareFlow")

    private let notificationDelegate = NotificationDelegate()

    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        IOSWatchConnectivityManager.shared.activate()

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
            print("Warning: Could not create persistent ModelContainer, attempting in-memory fallback: \(error)")
            
            do {
                let inMemoryConfig = ModelConfiguration(isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                print("CRITICAL: Could not create any ModelContainer: \(error)")
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

    private func handleShareURL(_ url: URL) {
        logger.debug("handleShareURL called with URL: \(url.absoluteString, privacy: .public)")
        guard url.host == "share",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            logger.debug("URL is not share deep link")
            return
        }

        let params = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item -> (String, String)? in
            guard let value = item.value else { return nil }
            return (item.name, value)
        })

        guard let reference = params["reference"],
              let text = params["text"],
              let bookName = params["bookName"],
              let chapterStr = params["chapter"],
              let chapter = Int(chapterStr),
              let verseStr = params["verse"],
              let verse = Int(verseStr),
              let translationName = params["translationName"],
              let translationId = params["translationId"] else {
            logger.debug("Share deep link missing required params")
            return
        }

        let pendingShareData = PendingShareData(
            reference: reference,
            text: text,
            bookName: bookName,
            chapter: chapter,
            verse: verse,
            translationName: translationName,
            translationId: translationId
        )

        let defaults = UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")
        defaults?.set([
            "reference": reference,
            "text": text,
            "bookName": bookName,
            "chapter": chapter,
            "verse": verse,
            "translationName": translationName,
            "translationId": translationId
        ], forKey: "pendingShareVerse")
        logger.debug("Share data posted from deep link and mirrored to defaults")
        NotificationCenter.default.post(name: .didTriggerShare, object: pendingShareData)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(preferredColorScheme)
                .onOpenURL { url in
                    handleShareURL(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
