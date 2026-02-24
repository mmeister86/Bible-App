//
//  DailyVerseViewModel.swift
//  Bible App
//

import Foundation

/// Drives the home / daily verse screen, using DailyVerseService for caching logic.
@MainActor @Observable
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
        UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")?
            .set(translation, forKey: "selectedTranslation")

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
    
    /// Load the same verse in a different translation (when user changes language)
    func loadVerseInNewTranslation(newTranslation: String) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        // Update shared defaults for widget synchronization
        UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")?
            .set(newTranslation, forKey: "selectedTranslation")

        do {
            let response = try await DailyVerseService.fetchAndCacheDailyVerseInNewTranslation(
                newTranslation: newTranslation
            )
            verse = response
        } catch {
            // Fall back to loading fresh verse in new translation
            do {
                let response = try await DailyVerseService.fetchAndCacheDailyVerse(
                    translation: newTranslation
                )
                verse = response
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    /// Force-refresh by clearing cache and fetching anew.
    func refresh() async {
        verse = nil
        await loadDailyVerse()
    }
}
