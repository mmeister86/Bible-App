//
//  CategoryVerseView.swift
//  Bible App
//

import SwiftUI
import SwiftData

/// Displays verses from a selected mood/life-situation category.
/// Users can navigate forward/backward through the curated verse list.
struct CategoryVerseView: View {
    let category: VerseCategory

    @State private var viewModel: CategoryVerseViewModel
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var showShareSheet = false
    @State private var verseID = UUID()
    @State private var cardAppeared = false
    @State private var navigationCount = 0
    @State private var favoriteToggleCount = 0
    @State private var shareTriggered = false
    @State private var navigatingForward = true

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var favorites: [FavoriteVerse]

    init(category: VerseCategory) {
        self.category = category
        self._viewModel = State(initialValue: CategoryVerseViewModel(category: category))
    }

    private var isFavorited: Bool {
        guard let verse = viewModel.verse else { return false }
        return favoritesViewModel.isFavorited(reference: verse.reference, in: favorites)
    }

    private var categoryColor: Color {
        Color(hex: category.accentColorHex)
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            content
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchCurrentVerse()
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: navigationCount)
        .sensoryFeedback(.impact(weight: .medium), trigger: favoriteToggleCount)
        .sensoryFeedback(.success, trigger: shareTriggered)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.verse == nil {
            LoadingView(message: "Loading verse...")
                .transition(.opacity)
        } else if let errorMessage = viewModel.errorMessage, viewModel.verse == nil {
            ErrorView(errorMessage: errorMessage) {
                Task { await viewModel.fetchCurrentVerse() }
            }
            .transition(.opacity)
        } else {
            mainContent
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // MARK: - Category Header
            categoryHeader
                .padding(.top, AppTheme.screenMargin)
                .padding(.bottom, AppTheme.itemSpacing)

            Spacer()

            // MARK: - Verse Card
            if let verse = viewModel.verse {
                ScrollView {
                    VerseCardView(response: verse)
                        .id(verseID)
                        .transition(.asymmetric(
                            insertion: .push(from: navigatingForward ? .trailing : .leading)
                                .combined(with: .opacity),
                            removal: .push(from: navigatingForward ? .leading : .trailing)
                                .combined(with: .opacity)
                        ))
                        .padding(.horizontal, AppTheme.screenMargin)
                        .scaleEffect(cardAppeared ? 1.0 : 0.95)
                        .opacity(cardAppeared ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                cardAppeared = true
                            }
                        }
                }
            }

            Spacer()

            // MARK: - Action Buttons
            actionButtons
                .padding(.bottom, AppTheme.screenMargin)

            // MARK: - Navigation Buttons
            navigationButtons
                .padding(.bottom, AppTheme.sectionGap)
        }
        .shareSheet(isPresented: $showShareSheet, items: shareItems)
    }

    // MARK: - Category Header

    private var categoryHeader: some View {
        VStack(spacing: 6) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(categoryColor)

            Text(viewModel.progress)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: AppTheme.sectionGap) {
            // Favorite toggle
            Button {
                guard let verse = viewModel.verse else { return }
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
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel(isFavorited ? "Remove from favorites" : "Add to favorites")

            // Share button
            Button {
                shareTriggered.toggle()
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundStyle(Color.secondaryText)
            }
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .accessibilityLabel("Share verse")
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: AppTheme.itemSpacing) {
            // Previous
            Button {
                navigationCount += 1
                navigatingForward = false
                Task {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        verseID = UUID()
                    }
                    await viewModel.previousVerse()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        verseID = UUID()
                    }
                }
            } label: {
                Label("Previous", systemImage: "chevron.left")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(viewModel.hasPrevious ? Color.primaryText : Color.secondaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.cardBackground)
                            .shadow(
                                color: AppTheme.cardShadowColor,
                                radius: 4,
                                y: 2
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.hasPrevious)
            .opacity(viewModel.hasPrevious ? 1.0 : 0.5)

            // Shuffle within category
            Button {
                navigationCount += 1
                navigatingForward = true
                Task {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        verseID = UUID()
                    }
                    await viewModel.shuffleInCategory()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        verseID = UUID()
                    }
                }
            } label: {
                Image(systemName: "shuffle")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(categoryColor)
                    )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)

            // Next
            Button {
                navigationCount += 1
                navigatingForward = true
                Task {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        verseID = UUID()
                    }
                    await viewModel.nextVerse()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        verseID = UUID()
                    }
                }
            } label: {
                Label("Next", systemImage: "chevron.right")
                    .font(.subheadline.weight(.medium))
                    .labelStyle(.trailingIcon)
                    .foregroundStyle(viewModel.hasNext ? Color.primaryText : Color.secondaryText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.cardBackground)
                            .shadow(
                                color: AppTheme.cardShadowColor,
                                radius: 4,
                                y: 2
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.hasNext)
            .opacity(viewModel.hasNext ? 1.0 : 0.5)
        }
        .padding(.horizontal, AppTheme.screenMargin)
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

    // MARK: - Background

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

// MARK: - Trailing Icon Label Style

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.title
            configuration.icon
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: TrailingIconLabelStyle { TrailingIconLabelStyle() }
}

#Preview {
    NavigationStack {
        CategoryVerseView(category: VerseCategory.allCategories[0])
            .modelContainer(for: FavoriteVerse.self, inMemory: true)
    }
}
