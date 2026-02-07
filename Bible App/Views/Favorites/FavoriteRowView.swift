//
//  FavoriteRowView.swift
//  Bible App
//

import SwiftUI

/// A card-style row for displaying a saved favorite verse in the favorites list.
/// Includes a subtle chevron indicator and clean layout.
struct FavoriteRowView: View {
    let favorite: FavoriteVerse

    /// Formatted saved date (e.g. "Feb 7, 2026")
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: favorite.savedAt)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Reference (bold)
                Text(favorite.reference)
                    .font(AppTheme.reference)
                    .foregroundStyle(Color.primaryText)

                // Truncated verse text
                Text(favorite.text)
                    .font(.body)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(3)
                    .lineSpacing(4)

                // Translation badge + saved date
                HStack {
                    Text(favorite.translationName)
                        .font(AppTheme.translationBadge)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.accentGold)
                        )

                    Spacer()

                    Text(formattedDate)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText.opacity(0.7))
                }
            }

            // Chevron indicator
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondaryText.opacity(0.4))
        }
        .padding(AppTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(
            color: AppTheme.cardShadowColor,
            radius: AppTheme.cardShadowRadius / 2,
            x: 0,
            y: AppTheme.cardShadowY / 2
        )
    }
}

#Preview {
    FavoriteRowView(
        favorite: {
            let fav = FavoriteVerse(
                reference: "John 3:16",
                text: "For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.",
                bookName: "John",
                chapter: 3,
                verse: 16,
                translationName: "World English Bible"
            )
            return fav
        }()
    )
    .padding(AppTheme.screenMargin)
}
