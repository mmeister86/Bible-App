//
//  WatchConnectivityManager.swift
//  DailyVerse WatchApp Watch App
//

import Foundation
import OSLog
import WatchConnectivity

enum WatchConnectivityManagerError: LocalizedError {
    case sessionUnavailable
    case notReachable
    case invalidResponse
    case missingVerse(String)

    var errorDescription: String? {
        switch self {
        case .sessionUnavailable:
            return "Watch-Verbindung ist auf diesem Geraet nicht verfuegbar."
        case .notReachable:
            return "iPhone nicht erreichbar. Bitte iPhone-App oeffnen."
        case .invalidResponse:
            return "Ungueltige Antwort vom iPhone erhalten."
        case .missingVerse(let message):
            return message
        }
    }
}

final class WatchConnectivityManager: NSObject {
    static let shared = WatchConnectivityManager()

    private let session = WCSession.default
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "WatchConnectivity")

    var onDailyVersePayload: ((DailyVerseTransferPayload) -> Void)?
    var onReachabilityChanged: ((Bool) -> Void)?

    var isReachable: Bool {
        WCSession.isSupported() && session.isReachable
    }

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else {
            logger.info("WCSession unsupported on watch")
            return
        }

        session.delegate = self
        session.activate()
    }

    func requestRandomVerse() async throws -> RandomVerseResponsePayload {
        guard WCSession.isSupported() else {
            throw WatchConnectivityManagerError.sessionUnavailable
        }

        guard session.isReachable else {
            throw WatchConnectivityManagerError.notReachable
        }

        let requestPayload = RandomVerseRequestPayload()
        let requestData = try WatchConnectivityPayloadCoder.encode(requestPayload)
        let message = [WatchConnectivityPayloadKey.randomVerseRequest: requestData]

        return try await withCheckedThrowingContinuation { continuation in
            session.sendMessage(message) { reply in
                guard let responseData = reply[WatchConnectivityPayloadKey.randomVerseResponse] as? Data else {
                    continuation.resume(throwing: WatchConnectivityManagerError.invalidResponse)
                    return
                }

                do {
                    let response = try WatchConnectivityPayloadCoder.decode(
                        RandomVerseResponsePayload.self,
                        from: responseData
                    )
                    guard response.requestID == requestPayload.requestID else {
                        continuation.resume(throwing: WatchConnectivityManagerError.invalidResponse)
                        return
                    }
                    continuation.resume(returning: response)
                } catch {
                    continuation.resume(throwing: error)
                }
            } errorHandler: { error in
                continuation.resume(throwing: error)
            }
        }
    }

    private func deliverDailyVersePayload(_ data: Data) {
        do {
            let payload = try WatchConnectivityPayloadCoder.decode(DailyVerseTransferPayload.self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.onDailyVersePayload?(payload)
            }
        } catch {
            logger.error("Failed to decode daily verse payload: \(error.localizedDescription, privacy: .public)")
        }
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            logger.error("Watch WCSession activation failed: \(error.localizedDescription, privacy: .public)")
        }

        if let contextData = session.receivedApplicationContext[WatchConnectivityPayloadKey.dailyVerseContext] as? Data {
            deliverDailyVersePayload(contextData)
        }

        DispatchQueue.main.async { [weak self] in
            self?.onReachabilityChanged?(session.isReachable)
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { [weak self] in
            self?.onReachabilityChanged?(session.isReachable)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let contextData = applicationContext[WatchConnectivityPayloadKey.dailyVerseContext] as? Data else {
            return
        }
        deliverDailyVersePayload(contextData)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard let contextData = message[WatchConnectivityPayloadKey.dailyVerseContext] as? Data else {
            return
        }
        deliverDailyVersePayload(contextData)
    }
}
