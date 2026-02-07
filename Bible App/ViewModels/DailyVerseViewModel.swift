//
//  DailyVerseViewModel.swift
//  Bible App
//

import Foundation

/// Drives the home / daily verse screen, using DailyVerseService for caching logic.
@Observable
final class DailyVerseViewModel {
    var verse: BibleResponse?
    var isLoading = false
    var errorMessage: String?

    /// Load the daily verse — uses cached version if fresh, otherwise fetches a new one.
    func loadDailyVerse() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let translation = UserDefaults.standard.string(forKey: "selectedTranslation") ?? "web"

        do {
            let response = try await DailyVerseService.fetchAndCacheDailyVerse(
                translation: translation
            )
            verse = response
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Force-refresh by clearing cache and fetching anew.
    func refresh() async {
        verse = nil
        await loadDailyVerse()
    }
}
