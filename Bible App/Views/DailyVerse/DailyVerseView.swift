//
//  DailyVerseView.swift
//  Bible App
//

import SwiftUI
import SwiftData
import OSLog

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
    @State private var pendingShareVerse: [String: Any]?
    private let logger = Logger(subsystem: "dev.matthiasmeister.Bible-App", category: "DailyVerseShareFlow")

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
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
            checkForPendingShare()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkForPendingShare()
            }
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: favoriteToggleCount)
        .sensoryFeedback(.success, trigger: shareTriggered)
        .shareSheet(isPresented: $showShareSheet, items: currentShareItems)
        .onReceive(NotificationCenter.default.publisher(for: .didTriggerShare)) { notification in
            if let shareData = notification.object as? PendingShareData {
                logger.debug("Received didTriggerShare notification for \(shareData.reference, privacy: .public)")
                pendingShareVerse = [
                    "reference": shareData.reference,
                    "text": shareData.text,
                    "bookName": shareData.bookName,
                    "chapter": shareData.chapter,
                    "verse": shareData.verse,
                    "translationName": shareData.translationName,
                    "translationId": shareData.translationId
                ]
                showShareSheet = true
                logger.debug("Share sheet opened from notification")
            }
        }
    }
    
    // MARK: - Loading Logic
    
    private func loadVerse() async {
        // Load cached verse from DailyVerseService (App Group, shared with Widget)
        if let cached = DailyVerseService.getCachedDailyVerse() {
            viewModel.verse = cached
            viewModel.isLoading = false
        }
        
        // Then fetch fresh data (DailyVerseService handles caching internally)
        await viewModel.loadDailyVerse()
    }
    
    // MARK: - Pending Share Handling
    
    private func checkForPendingShare() {
        let defaults = UserDefaults(suiteName: "group.dev.matthiasmeister.Bible-App")
        logger.debug("Checking pendingShareVerse in DailyVerseView")
        if let verseData = defaults?.dictionary(forKey: "pendingShareVerse") {
            defaults?.removeObject(forKey: "pendingShareVerse")
            logger.debug("pendingShareVerse found and removed in DailyVerseView")
            
            pendingShareVerse = verseData
            
            if let _ = verseData["reference"] as? String,
               let _ = verseData["text"] as? String {
                showShareSheet = true
                logger.debug("Share sheet opened from defaults in DailyVerseView")
            }
        } else {
            logger.debug("No pendingShareVerse found in DailyVerseView")
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
                        Task { @MainActor in
                            VerseShareView.preRender(for: verse)
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
            isRefreshing = false
        }
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

    private var currentShareItems: [Any] {
        if let verse = viewModel.verse {
            return shareItems(for: verse)
        } else if let verseData = pendingShareVerse {
            return shareItems(from: verseData)
        }
        return []
    }

    private func shareItems(for verse: BibleResponse) -> [Any] {
        var items: [Any] = [
            "\(verse.text.trimmingCharacters(in: .whitespacesAndNewlines))\n— \(verse.reference)"
        ]
        if let image = VerseShareView.renderImage(for: verse) {
            items.append(image)
        }
        return items
    }

    private func shareItems(from verseData: [String: Any]) -> [Any] {
        guard let text = verseData["text"] as? String,
              let reference = verseData["reference"] as? String else {
            return []
        }
        let items: [Any] = [
            "\(text.trimmingCharacters(in: .whitespacesAndNewlines))\n— \(reference)"
        ]
        return items
    }
}

#Preview {
    DailyVerseView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
