//
//  SearchView.swift
//  Bible App
//

import SwiftUI
import SwiftData

/// Search screen with `.searchable` modifier, recent searches as tappable chips,
/// suggested verses as a "Try these" section, and verse results displayed in a VerseCardView.
/// Includes smooth transitions, animations, and haptic feedback.
struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var showShareSheet = false
    @State private var resultAppeared = false
    @State private var favoriteToggleCount = 0
    @State private var shareTriggered = false

    @Environment(\.modelContext) private var modelContext
    @Query private var favorites: [FavoriteVerse]

    /// Suggested verses for the "Try these" section
    private let suggestedVerses = [
        "John 3:16",
        "Psalm 23",
        "Romans 8:28",
        "Philippians 4:13",
        "Proverbs 3:5-6"
    ]

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("Search")
            .searchable(
                text: $viewModel.searchText,
                prompt: "e.g. John 3:16, Romans 8:28"
            )
            .onSubmit(of: .search) {
                resultAppeared = false
                Task { await searchWithCache() }
            }
        }
        // Haptic feedback
        .sensoryFeedback(.impact(weight: .medium), trigger: favoriteToggleCount)
        .sensoryFeedback(.success, trigger: shareTriggered)
    }
    
    // MARK: - Search Logic
    
    private func searchWithCache() async {
        // Check cache first
        if let reference = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
           let cached = await VerseCacheService.shared.getCached(for: reference) {
            viewModel.result = cached
            viewModel.isLoading = false
            viewModel.errorMessage = nil
        }
        
        // Then perform network search
        await viewModel.search()
        
        // Cache the result
        if let result = viewModel.result {
            await VerseCacheService.shared.cache(result, for: viewModel.searchText)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.result == nil {
            // Show skeleton during initial search
            VStack(spacing: AppTheme.screenMargin) {
                VerseSkeletonView()
                    .padding(.horizontal, AppTheme.screenMargin)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.result == nil {
            errorState(errorMessage)
                .transition(.opacity)
        } else if let result = viewModel.result {
            SearchResultContentView(
                result: result,
                favorites: favorites,
                favoritesViewModel: favoritesViewModel,
                showShareSheet: $showShareSheet,
                resultAppeared: $resultAppeared,
                favoriteToggleCount: $favoriteToggleCount,
                shareTriggered: $shareTriggered,
                onClearSearch: {
                    viewModel.clearSearch()
                    resultAppeared = false
                }
            )
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        } else {
            emptyState
                .transition(.opacity)
        }
    }

    // MARK: - Empty State (Recent Searches + Suggested Verses)

    private var emptyState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.screenMargin) {
                // Recent Searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: AppTheme.itemSpacing) {
                        HStack {
                            Text("Recent Searches")
                                .font(AppTheme.reference)
                                .foregroundStyle(Color.secondaryText)

                            Spacer()

                            Button("Clear") {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.recentSearches = []
                                    UserDefaults.standard.removeObject(forKey: "recentSearches")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(Color.accentGold)
                            .accessibilityLabel("Clear recent searches")
                        }

                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { query in
                                Button {
                                    viewModel.searchText = query
                                    resultAppeared = false
                                    Task { await searchWithCache() }
                                } label: {
                                    Text(query)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.primaryText)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.cardBackground)
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.dividerColor, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Search for \(query)")
                            }
                        }
                    }
                    .accessibilityElement(children: .contain)
                }

                // "Try these" Suggested Verses
                VStack(alignment: .leading, spacing: AppTheme.itemSpacing) {
                    Text("Try these")
                        .font(AppTheme.reference)
                        .foregroundStyle(Color.secondaryText)

                    FlowLayout(spacing: 8) {
                        ForEach(suggestedVerses, id: \.self) { verse in
                            Button {
                                viewModel.searchText = verse
                                resultAppeared = false
                                Task { await searchWithCache() }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "book.fill")
                                        .font(.caption2)
                                        .foregroundStyle(Color.accentGold)
                                    Text(verse)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.primaryText)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.accentGold.opacity(0.1))
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.accentGold.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Search for \(verse)")
                        }
                    }
                }
                .accessibilityElement(children: .contain)

                // Hint
                VStack(spacing: 12) {
                    Image(systemName: "text.book.closed")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.secondaryText.opacity(0.5))
                        .accessibilityHidden(true)

                    Text("Search for a verse by reference")
                        .font(AppTheme.reference)
                        .foregroundStyle(Color.secondaryText)

                    Text("Enter a book, chapter, and verse — like \"John 3:16\" or \"Psalm 23:1-6\"")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, AppTheme.screenMargin)
                .accessibilityElement(children: .combine)
            }
            .padding(AppTheme.screenMargin)
        }
    }

    // MARK: - Error State

    private func errorState(_ message: String) -> some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Verse not found",
            message: "We couldn't find that verse. Please check the reference and try again.",
            action: {
                viewModel.clearSearch()
            },
            actionLabel: "Try a different search"
        )
    }
}

// MARK: - Search Result Content View

/// Extracted result view to narrow observation scope and prevent
/// NavigationStack layout feedback loops.
private struct SearchResultContentView: View {
    let result: BibleResponse
    let favorites: [FavoriteVerse]
    @Bindable var favoritesViewModel: FavoritesViewModel
    @Binding var showShareSheet: Bool
    @Binding var resultAppeared: Bool
    @Binding var favoriteToggleCount: Int
    @Binding var shareTriggered: Bool
    var onClearSearch: () -> Void

    @Environment(\.modelContext) private var modelContext

    private var isFavorited: Bool {
        favoritesViewModel.isFavorited(reference: result.reference, in: favorites)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.screenMargin) {
                VerseCardView(response: result)
                    .scaleEffect(resultAppeared ? 1.0 : 0.95)
                    .opacity(resultAppeared ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(AppTheme.cardAppearAnimation) {
                            resultAppeared = true
                        }
                    }

                ActionButtonsContainer(
                    isFavorited: isFavorited,
                    onFavoriteToggle: {
                        withAnimation(AppTheme.buttonSpringAnimation) {
                            favoritesViewModel.toggleFavorite(
                                for: result,
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

                Button {
                    onClearSearch()
                } label: {
                    Text("Search another verse")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.accentGold)
                }
                .frame(minWidth: AppTheme.minTouchTarget, minHeight: AppTheme.minTouchTarget)
                .accessibilityLabel("Clear search and search for another verse")
            }
            .padding(AppTheme.screenMargin)
        }
        .shareSheet(isPresented: $showShareSheet, items: shareItems(for: result))
    }

    private func shareItems(for result: BibleResponse) -> [Any] {
        var items: [Any] = [
            "\(result.text.trimmingCharacters(in: .whitespacesAndNewlines))\n— \(result.reference)"
        ]
        if let image = VerseShareView.renderImage(for: result) {
            items.append(image)
        }
        return items
    }
}

// MARK: - Flow Layout (for recent search chips)

/// A simple flow layout that wraps items to the next line when they exceed the available width.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: .unspecified
            )
        }
    }

    private struct LayoutResult {
        var positions: [CGPoint]
        var size: CGSize
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
            totalHeight = currentY + lineHeight
        }

        return LayoutResult(
            positions: positions,
            size: CGSize(width: totalWidth, height: totalHeight)
        )
    }
}

// MARK: - String Extension

extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}

#Preview {
    SearchView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
