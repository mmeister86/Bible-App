//
//  CategoryVerseViewModel.swift
//  Bible App
//

import Foundation
import SwiftUI

/// Drives the category verse screen — fetches and navigates through
/// curated verses for a selected mood/life-situation category.
@MainActor @Observable
final class CategoryVerseViewModel {
    let category: VerseCategory
    var currentIndex: Int = 0
    var verse: BibleResponse?
    var isLoading = false
    var errorMessage: String?

    /// In-memory cache to avoid re-fetching previously viewed verses.
    private var cache: [String: BibleResponse] = [:]

    init(category: VerseCategory) {
        self.category = category
    }

    /// The current verse reference string.
    var currentReference: String {
        category.verseReferences[currentIndex]
    }

    /// Human-readable progress, e.g. "3 of 10".
    var progress: String {
        "\(currentIndex + 1) of \(category.verseReferences.count)"
    }

    var hasNext: Bool {
        currentIndex < category.verseReferences.count - 1
    }

    var hasPrevious: Bool {
        currentIndex > 0
    }

    // MARK: - Actions

    /// Fetch the verse at the current index.
    func fetchCurrentVerse() async {
        let reference = currentReference

        // Return cached result if available
        if let cached = cache[reference] {
            withAnimation(.easeInOut(duration: 0.3)) {
                verse = cached
                errorMessage = nil
            }
            return
        }

        guard !isLoading else { return }

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = true
            errorMessage = nil
        }

        let translation = UserDefaults.standard.string(forKey: "selectedTranslation") ?? "web"

        do {
            let response = try await BibleAPIClient.fetchVerse(
                reference: reference,
                translation: translation
            )
            cache[reference] = response
            withAnimation(.easeInOut(duration: 0.3)) {
                verse = response
            }
        } catch {
            withAnimation(.easeInOut(duration: 0.3)) {
                errorMessage = error.localizedDescription
            }
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            isLoading = false
        }
    }

    /// Navigate to the next verse in the category.
    func nextVerse() async {
        guard hasNext else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            verse = nil
        }
        currentIndex += 1
        await fetchCurrentVerse()
    }

    /// Navigate to the previous verse in the category.
    func previousVerse() async {
        guard hasPrevious else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            verse = nil
        }
        currentIndex -= 1
        await fetchCurrentVerse()
    }

    /// Shuffle to a random verse within this category.
    func shuffleInCategory() async {
        let newIndex = (0..<category.verseReferences.count)
            .filter { $0 != currentIndex }
            .randomElement() ?? 0
        withAnimation(.easeInOut(duration: 0.3)) {
            verse = nil
        }
        currentIndex = newIndex
        await fetchCurrentVerse()
    }
}
