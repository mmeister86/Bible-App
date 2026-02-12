//
//  FavoritesView.swift
//  Bible App
//

import SwiftUI
import SwiftData

/// List of saved favorite verses, sorted newest first, with swipe-to-delete,
/// animated list transitions, engaging empty state, and navigation to detail view.
struct FavoritesView: View {
    @Query(sort: \FavoriteVerse.savedAt, order: .reverse)
    private var favorites: [FavoriteVerse]

    @Environment(\.modelContext) private var modelContext
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var selectedFavorite: FavoriteVerse?
    @State private var deleteCount = 0

    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    EmptyStateView.favorites
                        .transition(.opacity)
                } else {
                    favoritesList
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: favorites.isEmpty)
            .navigationTitle("Favorites")
        }
        // Haptic feedback on delete
        .sensoryFeedback(.impact(weight: .light), trigger: deleteCount)
    }

    // MARK: - Favorites List

    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.itemSpacing) {
                ForEach(favorites) { favorite in
                    FavoriteRowView(favorite: favorite)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFavorite = favorite
                        }
                        .swipeToDelete {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                favoritesViewModel.removeFavorite(favorite, context: modelContext)
                            }
                            deleteCount += 1
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    favoritesViewModel.removeFavorite(favorite, context: modelContext)
                                }
                                deleteCount += 1
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            if let shareText = shareText(for: favorite) {
                                ShareLink(item: shareText) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                            }
                            
                            Button {
                                UIPasteboard.general.string = favorite.text
                            } label: {
                                Label("Copy Text", systemImage: "doc.on.doc")
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .slide.combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(favorite.reference), \(favorite.text)")
                        .accessibilityHint("Double-tap to view details, swipe left to delete")
                }
            }
            .padding(.horizontal, AppTheme.screenMargin)
            .padding(.vertical, AppTheme.itemSpacing)
        }
        .navigationDestination(item: $selectedFavorite) { favorite in
            FavoriteDetailView(
                favorite: favorite,
                favoritesViewModel: favoritesViewModel
            )
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        EmptyStateView.favorites
    }

    // MARK: - Helpers

    private func shareText(for favorite: FavoriteVerse) -> String? {
        "\(favorite.text)\n— \(favorite.reference)"
    }
}

// MARK: - Favorite Detail View

/// Full-screen detail view for a saved favorite, reusing VerseCardView
/// by converting the FavoriteVerse back into a BibleResponse.
private struct FavoriteDetailView: View {
    let favorite: FavoriteVerse
    let favoritesViewModel: FavoritesViewModel

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showShareSheet = false
    @State private var cardAppeared = false
    @State private var deleteTriggered = false
    @State private var shareTriggered = false

    /// Convert FavoriteVerse back to a BibleResponse for display in VerseCardView.
    private var asBibleResponse: BibleResponse {
        BibleResponse(
            reference: favorite.reference,
            verses: [
                VerseEntry(
                    bookId: "",
                    bookName: favorite.bookName,
                    chapter: favorite.chapter,
                    verse: favorite.verse,
                    text: favorite.text
                )
            ],
            text: favorite.text,
            translationId: "",
            translationName: favorite.translationName,
            translationNote: ""
        )
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient(for: colorScheme)
                .ignoresSafeArea()

            VStack {
                Spacer()

                ScrollView {
                    VerseCardView(response: asBibleResponse)
                        .padding(.horizontal, AppTheme.screenMargin)
                        .scaleEffect(cardAppeared ? 1.0 : 0.95)
                        .opacity(cardAppeared ? 1.0 : 0.0)
                        .onAppear {
                            withAnimation(AppTheme.cardAppearAnimation) {
                                cardAppeared = true
                            }
                        }
                }

                Spacer()

                // Action buttons
                HStack(spacing: AppTheme.sectionGap) {
                    ActionButtonView.delete {
                        deleteTriggered.toggle()
                        withAnimation {
                            favoritesViewModel.removeFavorite(favorite, context: modelContext)
                        }
                        dismiss()
                    }

                    ActionButtonView.share {
                        shareTriggered.toggle()
                        showShareSheet = true
                    }
                }
                .padding(.bottom, AppTheme.sectionGap)
            }
        }
        .navigationTitle(favorite.reference)
        .navigationBarTitleDisplayMode(.inline)
        .shareSheet(isPresented: $showShareSheet, items: [
            "\(favorite.text)\n— \(favorite.reference)"
        ])
        .sensoryFeedback(.impact(weight: .heavy), trigger: deleteTriggered)
        .sensoryFeedback(.success, trigger: shareTriggered)
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: FavoriteVerse.self, inMemory: true)
}
