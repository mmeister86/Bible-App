//
//  FavoritesViewModel.swift
//  Bible App
//

import Foundation
import SwiftData

/// Handles favorite verse mutations. Favorites data is fetched via @Query in the view;
/// this ViewModel handles add, remove, and lookup operations only.
@Observable
final class FavoritesViewModel {

    /// Create a FavoriteVerse from a BibleResponse and insert it into the model context.
    func addFavorite(from response: BibleResponse, context: ModelContext) {
        let firstVerse = response.verses.first
        let favorite = FavoriteVerse(
            reference: response.reference,
            text: response.text.trimmingCharacters(in: .whitespacesAndNewlines),
            bookName: firstVerse?.bookName ?? "",
            chapter: firstVerse?.chapter ?? 0,
            verse: firstVerse?.verse ?? 0,
            translationName: response.translationName
        )
        context.insert(favorite)
    }

    /// Remove a FavoriteVerse from the model context.
    func removeFavorite(_ favorite: FavoriteVerse, context: ModelContext) {
        context.delete(favorite)
    }

    /// Check whether a given reference string already exists in the favorites array.
    func isFavorited(reference: String, in favorites: [FavoriteVerse]) -> Bool {
        favorites.contains { $0.reference == reference }
    }

    /// Find and remove a favorite by its reference string.
    func removeFavorite(byReference reference: String, in favorites: [FavoriteVerse], context: ModelContext) {
        if let existing = favorites.first(where: { $0.reference == reference }) {
            context.delete(existing)
        }
    }

    /// Toggle favorite status for a given BibleResponse.
    func toggleFavorite(for response: BibleResponse, in favorites: [FavoriteVerse], context: ModelContext) {
        if isFavorited(reference: response.reference, in: favorites) {
            removeFavorite(byReference: response.reference, in: favorites, context: context)
        } else {
            addFavorite(from: response, context: context)
        }
    }
}
