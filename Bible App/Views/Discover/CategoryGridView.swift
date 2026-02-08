//
//  CategoryGridView.swift
//  Bible App
//

import SwiftUI

/// A 2-column grid of mood/life-situation category tiles.
/// Each tile navigates to a `CategoryVerseView` via `NavigationLink(value:)`.
struct CategoryGridView: View {
    @State private var appeared = false

    private let columns = [
        GridItem(.flexible(), spacing: AppTheme.itemSpacing),
        GridItem(.flexible(), spacing: AppTheme.itemSpacing)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppTheme.itemSpacing) {
            ForEach(VerseCategory.allCategories) { category in
                NavigationLink(value: category) {
                    CategoryTileView(category: category)
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(appeared ? 1.0 : 0.0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Category Tile

private struct CategoryTileView: View {
    let category: VerseCategory

    private var accentColor: Color {
        Color(hex: category.accentColorHex)
    }

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(accentColor)
                )

            VStack(spacing: 4) {
                Text(category.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primaryText)

                Text(category.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                .fill(Color.cardBackground)
                .shadow(
                    color: AppTheme.cardShadowColor,
                    radius: AppTheme.cardShadowRadius / 2,
                    y: AppTheme.cardShadowY / 2
                )
        )
    }
}

#Preview {
    NavigationStack {
        ScrollView {
            CategoryGridView()
                .padding(.horizontal, AppTheme.screenMargin)
        }
    }
}
