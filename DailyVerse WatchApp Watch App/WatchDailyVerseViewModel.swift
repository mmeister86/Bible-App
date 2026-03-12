//
//  WatchDailyVerseViewModel.swift
//  DailyVerse WatchApp Watch App
//

import Foundation

@MainActor
@Observable
final class WatchDailyVerseViewModel {
    private static let cachedPayloadKey = "watch.cachedDailyVersePayload"

    private let manager: WatchConnectivityManager
    private let defaults: UserDefaults
    private var dailyVersePayload: DailyVerseTransferPayload?

    var verse: BibleResponse?
    var selectedTranslation: String = "web"
    var statusMessage: String?
    var isRandomVerseLoading = false
    private(set) var isShowingRandomVerse = false

    init() {
        self.manager = .shared
        self.defaults = .standard
        configureCallbacks()
        restoreCachedVerseIfAvailable()
    }

    init(
        manager: WatchConnectivityManager,
        defaults: UserDefaults = .standard
    ) {
        self.manager = manager
        self.defaults = defaults

        configureCallbacks()
        restoreCachedVerseIfAvailable()
    }

    private func configureCallbacks() {
        manager.onDailyVersePayload = { [weak self] payload in
            Task { @MainActor in
                self?.applyDailyVersePayload(payload)
            }
        }

        manager.onReachabilityChanged = { [weak self] isReachable in
            Task { @MainActor in
                self?.updateStatusForReachability(isReachable)
            }
        }
    }

    func requestRandomVerse() async {
        guard !isRandomVerseLoading else {
            return
        }

        guard manager.isReachable else {
            statusMessage = "iPhone nicht erreichbar. Oeffne die iPhone-App."
            return
        }

        isRandomVerseLoading = true
        defer { isRandomVerseLoading = false }

        do {
            let response = try await manager.requestRandomVerse()

            if let errorMessage = response.errorMessage {
                statusMessage = errorMessage
                return
            }

            guard let verse = response.verse else {
                statusMessage = WatchConnectivityManagerError.invalidResponse.localizedDescription
                return
            }

            self.verse = verse
            selectedTranslation = response.selectedTranslation
            statusMessage = nil
            isShowingRandomVerse = true
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func applyDailyVersePayload(_ payload: DailyVerseTransferPayload) {
        dailyVersePayload = payload
        cache(payload: payload)

        guard !isShowingRandomVerse else {
            return
        }

        verse = payload.verse
        selectedTranslation = payload.selectedTranslation
        statusMessage = nil
    }

    func showDailyVerse() {
        guard let dailyVersePayload else {
            statusMessage = "Kein gespeicherter Tagesvers verfuegbar."
            return
        }

        verse = dailyVersePayload.verse
        selectedTranslation = dailyVersePayload.selectedTranslation
        statusMessage = nil
        isShowingRandomVerse = false
    }

    private func updateStatusForReachability(_ isReachable: Bool) {
        if isReachable {
            if verse != nil {
                statusMessage = nil
            }
        } else if verse == nil {
            statusMessage = "Kein synchronisierter Tagesvers verfuegbar. Oeffne die iPhone-App."
        } else {
            statusMessage = "Offline: Letzter synchronisierter Vers"
        }
    }

    private func restoreCachedVerseIfAvailable() {
        guard let data = defaults.data(forKey: Self.cachedPayloadKey) else {
            statusMessage = "Warte auf iPhone-Synchronisierung"
            return
        }

        do {
            let payload = try WatchConnectivityPayloadCoder.decode(DailyVerseTransferPayload.self, from: data)
            applyDailyVersePayload(payload)
        } catch {
            statusMessage = "Warte auf iPhone-Synchronisierung"
        }
    }

    private func cache(payload: DailyVerseTransferPayload) {
        if let data = try? WatchConnectivityPayloadCoder.encode(payload) {
            defaults.set(data, forKey: Self.cachedPayloadKey)
        }
    }
}
