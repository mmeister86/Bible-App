//
//  SearchViewModel.swift
//  Bible App
//

import Foundation

/// Drives the search screen with verse lookup and recent search history.
@MainActor @Observable
final class SearchViewModel {
    var searchText = ""
    var result: BibleResponse?
    var isLoading = false
    var errorMessage: String?
    var recentSearches: [String] = []

    private static let recentSearchesKey = "recentSearches"
    private static let maxRecentSearches = 10

    init() {
        loadRecentSearches()
    }

    /// Search for a verse by reference using the API.
    func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        let translation = UserDefaults.standard.string(forKey: "selectedTranslation") ?? "web"

        do {
            let response = try await BibleAPIClient.fetchVerse(
                reference: query,
                translation: translation
            )
            result = response
            addToRecent(query)
        } catch let error as BibleAPIError {
            switch error {
            case .notFound:
                errorMessage = "Verse not found. Try e.g. John 3:16"
            default:
                errorMessage = error.localizedDescription
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Clear the current search result and text.
    func clearSearch() {
        searchText = ""
        result = nil
        errorMessage = nil
    }

    /// Add a query to the recent searches list (most recent first, max 10).
    func addToRecent(_ query: String) {
        // Remove if already in list to avoid duplicates, then prepend
        recentSearches.removeAll { $0.lowercased() == query.lowercased() }
        recentSearches.insert(query, at: 0)

        // Trim to max
        if recentSearches.count > Self.maxRecentSearches {
            recentSearches = Array(recentSearches.prefix(Self.maxRecentSearches))
        }

        saveRecentSearches()
    }

    /// Load recent searches from UserDefaults.
    func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: Self.recentSearchesKey) ?? []
    }

    // MARK: - Private

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: Self.recentSearchesKey)
    }
}
