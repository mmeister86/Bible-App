//
//  RandomVerseView.swift
//  Bible App
//

import SwiftUI
import SwiftData

/// Discover screen — displays a random verse with a shuffle button
/// and smooth spring animations between verse changes.
/// Includes haptic feedback, card appear transitions, and dark mode support.
struct RandomVerseView: View {
    var showHeader: Bool = true

    @State private var viewModel = RandomVerseViewModel()
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var showShareSheet = false
    @State private var verseID = UUID()
    @State private var cardAppeared = false
    @State private var shuffleCount = 0
    @State private var favoriteToggleCount = 0
    @State private var shareTriggered = false

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var favorites: [FavoriteVerse]

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
            guard !viewModel.hasAppeared else { return }
            viewModel.hasAppeared = true
            await viewModel.fetchRandomVerse()
        }
        // Haptic feedback
        .sensoryFeedback(.impact(weight: .medium), trigger: shuffleCount)
        .sensoryFeedback(.impact(weight: .medium), trigger: favoriteToggleCount)
        .sensoryFeedback(.success, trigger: shareTriggered)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.verse == nil {
            VStack(spacing: 0) {
                if showHeader {
                    headerView
                }
                Spacer()
                VerseSkeletonView()
                    .padding(.horizontal, AppTheme.screenMargin)
                Spacer()
                shuffleButton
                    .padding(.bottom, AppTheme.sectionGap)
            }
            .transition(.opacity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.verse == nil {
            ErrorView(errorMessage: errorMessage) {
                Task { await viewModel.fetchRandomVerse() }
            }
            .transition(.opacity)
        } else {
            mainContent
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            if showHeader {
                headerView
            }

            Spacer()

            // MARK: - Verse Card
            if let verse = viewModel.verse {
                ScrollView {
                    VerseCardView(response: verse)
                        .id(verseID)
                        .transition(.asymmetric(
                            insertion: .push(from: .bottom).combined(with: .opacity),
                            removal: .push(from: .top).combined(with: .opacity)
                        ))
                        .padding(.horizontal, AppTheme.screenMargin)
                        .scaleEffect(cardAppeared ? 1.0 : 0.95)
                        .opacity(cardAppeared ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(AppTheme.cardAppearAnimation) {
                                cardAppeared = true
                            }
                        }
                }
            }

            Spacer()

            // MARK: - Action Buttons
            ActionButtonsContainer(
                isFavorited: isFavorited,
                onFavoriteToggle: {
                    guard let verse = viewModel.verse else { return }
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
            .padding(.bottom, AppTheme.screenMargin)

            // MARK: - Shuffle Button
            shuffleButton
                .padding(.bottom, AppTheme.sectionGap)
        }
        .shareSheet(isPresented: $showShareSheet, items: shareItems)
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text("Discover")
            .font(AppTheme.heading)
            .foregroundStyle(Color.primaryText)
            .padding(.top, AppTheme.sectionGap)
            .padding(.bottom, AppTheme.screenMargin)
            .accessibilityAddTraits(.isHeader)
    }
    
    private var shuffleButton: some View {
        Button {
            shuffleCount += 1
            Task {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    verseID = UUID()
                }
                await viewModel.shuffle()
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    verseID = UUID()
                }
            }
        } label: {
            Label("Shuffle", systemImage: "shuffle")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.accentGold)
                )
                .shadow(
                    color: Color.accentGold.opacity(0.3),
                    radius: 8,
                    y: 4
                )
        }
        .accessibilityLabel("Load new verse")
        .accessibilityHint("Double-tap to discover a new random verse")
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.6 : 1.0)
        .scaleEffect(viewModel.isLoading ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isLoading)
    }

    // MARK: - Share Items

    private var shareItems: [Any] {
        guard let verse = viewModel.verse else { return [] }
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
    RandomVerseView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
