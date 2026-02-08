//
//  SearchViewModel.swift
//  Bible App
//

import Foundation
import SwiftUI

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

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
            errorMessage = nil
        }

        let translation = UserDefaults.standard.string(forKey: "selectedTranslation") ?? "web"

        do {
            let response = try await BibleAPIClient.fetchVerse(
                reference: query,
                translation: translation
            )
            withAnimation(.easeInOut(duration: 0.3)) {
                result = response
                isLoading = false
            }
            addToRecent(query)
        } catch let error as BibleAPIError {
            withAnimation(.easeInOut(duration: 0.3)) {
                switch error {
                case .notFound:
                    errorMessage = "Verse not found. Try e.g. John 3:16"
                default:
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        } catch {
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    /// Clear the current search result and text.
    func clearSearch() {
        withAnimation(.easeInOut(duration: 0.3)) {
            searchText = ""
            result = nil
            errorMessage = nil
        }
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
