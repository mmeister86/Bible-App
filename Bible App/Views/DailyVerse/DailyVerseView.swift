//
//  DailyVerseView.swift
//  Bible App
//

import SwiftUI
import SwiftData

/// Home screen showing the verse of the day with beautiful typography
/// and a premium, full-screen card layout. Includes smooth transitions
/// between loading/content/error states, haptic feedback, and animations.
struct DailyVerseView: View {
    @State private var viewModel = DailyVerseViewModel()
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var showShareSheet = false
    @State private var cardAppeared = false
    @State private var favoriteToggleCount = 0
    @State private var shareTriggered = false
    @State private var isRefreshing = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var favorites: [FavoriteVerse]

    /// Formatted date string for the heading (e.g. "Saturday, February 7")
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: Date())
    }

    /// Whether the current verse is favorited
    private var isFavorited: Bool {
        guard let verse = viewModel.verse else { return false }
        return favoritesViewModel.isFavorited(reference: verse.reference, in: favorites)
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()

            content
        }
        .task {
            await loadVerse()
        }
        // Haptic feedback for favorite toggle
        .sensoryFeedback(.impact(weight: .medium), trigger: favoriteToggleCount)
        // Haptic feedback for share
        .sensoryFeedback(.success, trigger: shareTriggered)
    }
    
    // MARK: - Loading Logic
    
    private func loadVerse() async {
        // Try to load cached verse first for instant display
        if let cached = await VerseCacheService.shared.getCachedDailyVerse() {
            viewModel.verse = cached
            viewModel.isLoading = false
        }
        
        // Then fetch fresh data
        await viewModel.loadDailyVerse()
        
        // Cache the result
        if let verse = viewModel.verse {
            await VerseCacheService.shared.cacheDailyVerse(verse)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.verse == nil {
            // Show skeleton during initial load
            VStack(spacing: 0) {
                headerView
                Spacer()
                VerseSkeletonView()
                    .padding(.horizontal, AppTheme.screenMargin)
                Spacer()
                bottomHintView
            }
            .transition(.opacity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.verse == nil {
            // Show error state
            ErrorView(errorMessage: errorMessage) {
                Task { await loadVerse() }
            }
            .transition(.opacity)
        } else if let verse = viewModel.verse {
            verseContent(verse)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private func verseContent(_ verse: BibleResponse) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Header
                headerView
                
                Spacer()
                    .frame(height: AppTheme.screenMargin)

                // MARK: - Verse Card (animated appear)
                VerseCardView(response: verse)
                    .padding(.horizontal, AppTheme.screenMargin)
                    .scaleEffect(cardAppeared ? 1.0 : 0.95)
                    .opacity(cardAppeared ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(AppTheme.cardAppearAnimation) {
                            cardAppeared = true
                        }
                    }

                // MARK: - Action Buttons
                ActionButtonsContainer(
                    isFavorited: isFavorited,
                    onFavoriteToggle: {
                        withAnimation(AppTheme.buttonSpringAnimation) {
                            favoritesViewModel.toggleFavorite(
                                for: verse,
                                in: favorites,
                                context: modelContext
                            )
                        }
                        favoriteToggleCount += 1
                    },
                    onShare: {
                        shareTriggered.toggle()
                        showShareSheet = true
                    }
                )
                .padding(.top, AppTheme.sectionGap)

                // MARK: - Bottom Hint
                bottomHintView
            }
        }
        .refreshable {
            isRefreshing = true
            await viewModel.refresh()
            if let verse = viewModel.verse {
                await VerseCacheService.shared.cacheDailyVerse(verse)
            }
            isRefreshing = false
        }
        .shareSheet(isPresented: $showShareSheet, items: shareItems(for: verse))
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 4) {
            Text("Verse of the Day")
                .font(AppTheme.heading)
                .foregroundStyle(Color.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text(formattedDate)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .padding(.top, AppTheme.sectionGap)
        .padding(.bottom, AppTheme.screenMargin)
    }
    
    private var bottomHintView: some View {
        VStack(spacing: 4) {
            Text("Pull down to refresh")
                .font(.caption)
                .foregroundStyle(Color.secondaryText.opacity(0.6))
            
            Text("Refreshes each day with a new verse")
                .font(.caption2)
                .foregroundStyle(Color.secondaryText.opacity(0.5))
        }
        .padding(.bottom, AppTheme.screenMargin)
        .accessibilityHidden(true)
    }

    // MARK: - Share Items

    private func shareItems(for verse: BibleResponse) -> [Any] {
        var items: [Any] = [
            "\(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))\n— \(verse.reference)"
        ]
        if let image = VerseShareView.renderImage(for: verse) {
            items.append(image)
        }
        return items
    }
}

#Preview {
    DailyVerseView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
