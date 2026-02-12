//
//  DiscoverView.swift
//  Bible App
//

import SwiftUI
import SwiftData

/// Container view for the Discover tab.
/// Shows a category grid as the main view with a prominent
/// "Random Verse" button for shuffle functionality.
struct DiscoverView: View {
    @State private var showRandomVerse = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.screenMargin) {
                    // MARK: - Header
                    Text("Discover")
                        .font(AppTheme.heading)
                        .foregroundStyle(Color.primaryText)
                        .padding(.top, AppTheme.sectionGap)
                        .frame(maxWidth: .infinity)
                        .accessibilityAddTraits(.isHeader)

                    // MARK: - Random Verse Button
                    randomVerseButton
                        .padding(.horizontal, AppTheme.screenMargin)

                    // MARK: - By Mood Section
                    Text("By Mood")
                        .font(.headline)
                        .foregroundStyle(Color.secondaryText)
                        .padding(.horizontal, AppTheme.screenMargin)
                        .accessibilityAddTraits(.isHeader)

                    CategoryGridView()
                        .padding(.horizontal, AppTheme.screenMargin)
                        .padding(.bottom, AppTheme.sectionGap)
                }
            }
            .background(AppTheme.backgroundGradient(for: colorScheme).ignoresSafeArea())
            .navigationDestination(for: VerseCategory.self) { category in
                CategoryVerseView(category: category)
            }
            .navigationDestination(isPresented: $showRandomVerse) {
                RandomVerseView(showHeader: false)
                    .navigationTitle("Random Verse")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    // MARK: - Random Verse Button

    private var randomVerseButton: some View {
        Button {
            showRandomVerse = true
        } label: {
            HStack(spacing: AppTheme.itemSpacing) {
                ZStack {
                    Circle()
                        .fill(Color.accentGold)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "shuffle")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Random Verse")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.primaryText)

                    Text("Discover something unexpected")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(AppTheme.itemSpacing + 4)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .fill(Color.cardBackground)
                    .shadow(
                        color: AppTheme.cardShadowColor,
                        radius: AppTheme.cardShadowRadius,
                        y: AppTheme.cardShadowY
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Get a random Bible verse")
        .accessibilityHint("Double-tap to discover a random verse")
    }
}

#Preview {
    DiscoverView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
