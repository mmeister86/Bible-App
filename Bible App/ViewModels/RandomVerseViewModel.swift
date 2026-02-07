//
//  RandomVerseViewModel.swift
//  Bible App
//

import Foundation

/// Drives the random verse / discover screen with shuffle animation support.
@Observable
final class RandomVerseViewModel {
    var verse: BibleResponse?
    var isLoading = false
    var errorMessage: String?
    var hasAppeared = false

    /// Fetch a random verse from the API.
    func fetchRandomVerse() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let translation = UserDefaults.standard.string(forKey: "selectedTranslation") ?? "web"

        do {
            let response = try await BibleAPIClient.fetchRandomVerse(translation: translation)
            verse = response
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Shuffle to a new random verse — clears current verse for transition, then fetches.
    func shuffle() async {
        verse = nil
        await fetchRandomVerse()
    }
}
