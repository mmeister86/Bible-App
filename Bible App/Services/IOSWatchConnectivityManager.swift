//
//  IOSWatchConnectivityManager.swift
//  Bible App
//

import Foundation
import OSLog
import WatchConnectivity

final class IOSWatchConnectivityManager: NSObject {
    static let shared = IOSWatchConnectivityManager()

    private static let appGroupID = "group.dev.matthiasmeister.Bible-App"
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "iOSWatchConnectivity")
    private let session = WCSession.default

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else {
            logger.info("WCSession not supported on this device")
            return
        }

        session.delegate = self
        session.activate()
    }

    func sendDailyVerseUpdate(_ verse: BibleResponse) {
        guard WCSession.isSupported() else {
            return
        }

        let selectedTranslation = UserDefaults(suiteName: Self.appGroupID)?.string(forKey: "selectedTranslation")
            ?? verse.translationId

        let payload = DailyVerseTransferPayload(
            verse: verse,
            selectedTranslation: selectedTranslation,
            generatedAt: Date()
        )

        do {
            let encodedPayload = try WatchConnectivityPayloadCoder.encode(payload)
            let message = [WatchConnectivityPayloadKey.dailyVerseContext: encodedPayload]

            do {
                try session.updateApplicationContext(message)
            } catch {
                logger.error("Failed to update app context: \(error.localizedDescription, privacy: .public)")
            }

            session.transferUserInfo(message)

            if session.isReachable {
                session.sendMessage(message, replyHandler: nil) { [logger] error in
                    logger.error("Failed to send live daily verse message: \(error.localizedDescription, privacy: .public)")
                }
            }
        } catch {
            logger.error("Failed to encode daily verse payload: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func sendCachedDailyVerseIfAvailable() {
        guard let cached = DailyVerseService.getCachedDailyVerse() else {
            return
        }
        sendDailyVerseUpdate(cached)
    }

    private func handleRandomVerseRequest(_ data: Data, replyHandler: @escaping ([String: Any]) -> Void) {
        let request: RandomVerseRequestPayload
        do {
            request = try WatchConnectivityPayloadCoder.decode(RandomVerseRequestPayload.self, from: data)
        } catch {
            logger.error("Failed to decode random verse request: \(error.localizedDescription, privacy: .public)")
            return
        }

        Task {
            let selectedTranslation = UserDefaults(suiteName: Self.appGroupID)?.string(forKey: "selectedTranslation") ?? "web"

            let responsePayload: RandomVerseResponsePayload
            do {
                let verse = try await BibleAPIClient.fetchRandomVerse(translation: selectedTranslation)
                responsePayload = RandomVerseResponsePayload(
                    requestID: request.requestID,
                    verse: verse,
                    selectedTranslation: selectedTranslation,
                    generatedAt: Date(),
                    errorMessage: nil
                )
            } catch {
                responsePayload = RandomVerseResponsePayload(
                    requestID: request.requestID,
                    verse: nil,
                    selectedTranslation: selectedTranslation,
                    generatedAt: Date(),
                    errorMessage: error.localizedDescription
                )
            }

            do {
                let encodedResponse = try WatchConnectivityPayloadCoder.encode(responsePayload)
                replyHandler([WatchConnectivityPayloadKey.randomVerseResponse: encodedResponse])
            } catch {
                logger.error("Failed to encode random verse response: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

extension IOSWatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            logger.error("WCSession activation failed: \(error.localizedDescription, privacy: .public)")
            return
        }

        logger.debug("WCSession activated with state \(activationState.rawValue, privacy: .public)")
        sendCachedDailyVerseIfAvailable()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.debug("WCSession became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        logger.debug("WCSession deactivated, reactivating")
        session.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            sendCachedDailyVerseIfAvailable()
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard let data = message[WatchConnectivityPayloadKey.randomVerseRequest] as? Data else {
            return
        }

        handleRandomVerseRequest(data, replyHandler: replyHandler)
    }
}
