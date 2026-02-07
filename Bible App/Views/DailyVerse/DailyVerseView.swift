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

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var favorites: [FavoriteVerse]

    /// Formatted date string for the heading (e.g. "Saturday, February 7")
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    /// Whether the current verse is favorited
    private var isFavorited: Bool {
        guard let verse = viewModel.verse else { return false }
        return favoritesViewModel.isFavorited(reference: verse.reference, in: favorites)
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            content
        }
        .task {
            await viewModel.loadDailyVerse()
        }
        // Haptic feedback for favorite toggle
        .sensoryFeedback(.impact(weight: .medium), trigger: favoriteToggleCount)
        // Haptic feedback for share
        .sensoryFeedback(.success, trigger: shareTriggered)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView(message: "Loading verse of the day...")
                .transition(.opacity)
        } else if let errorMessage = viewModel.errorMessage {
            ErrorView(errorMessage: errorMessage) {
                Task { await viewModel.refresh() }
            }
            .transition(.opacity)
        } else if let verse = viewModel.verse {
            verseContent(verse)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private func verseContent(_ verse: BibleResponse) -> some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack(spacing: 4) {
                Text("Verse of the Day")
                    .font(AppTheme.heading)
                    .foregroundStyle(Color.primaryText)

                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.top, AppTheme.sectionGap)
            .padding(.bottom, AppTheme.screenMargin)

            Spacer()

            // MARK: - Verse Card (animated appear)
            ScrollView {
                VerseCardView(response: verse)
                    .padding(.horizontal, AppTheme.screenMargin)
                    .scaleEffect(cardAppeared ? 1.0 : 0.95)
                    .opacity(cardAppeared ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            cardAppeared = true
                        }
                    }
            }

            Spacer()

            // MARK: - Action Buttons
            HStack(spacing: AppTheme.sectionGap) {
                // Favorite toggle
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favoritesViewModel.toggleFavorite(
                            for: verse,
                            in: favorites,
                            context: modelContext
                        )
                    }
                    favoriteToggleCount += 1
                } label: {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(isFavorited ? .red : Color.secondaryText)
                        .symbolEffect(.bounce, value: isFavorited)
                        .contentTransition(.symbolEffect(.replace))
                }

                // Share button
                Button {
                    shareTriggered.toggle()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            .padding(.bottom, AppTheme.sectionGap)

            // Refreshes tomorrow note
            Text("Refreshes each day with a new verse")
                .font(.caption)
                .foregroundStyle(Color.secondaryText.opacity(0.7))
                .padding(.bottom, AppTheme.screenMargin)
        }
        .shareSheet(isPresented: $showShareSheet, items: shareItems(for: verse))
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

    // MARK: - Background (adapts to color scheme)

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(hex: "#1C1C1E"), Color(.systemBackground)]
                : [Color.cardBackground.opacity(0.5), Color(.systemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    DailyVerseView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
