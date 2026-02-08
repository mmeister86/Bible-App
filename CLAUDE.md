# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```bash
# Build
xcodebuild -scheme "Bible App" -destination "platform=iOS Simulator,name=iPhone 16" build

# Run all unit tests
xcodebuild -scheme "Bible App" -destination "platform=iOS Simulator,name=iPhone 16" test

# Run a single test (by name)
xcodebuild -scheme "Bible App" -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:"Bible AppTests/Bible_AppTests/testName" test
```

No linter is configured. No third-party dependencies — the project uses only Apple frameworks.

## Architecture

MVVM with SwiftUI, targeting iOS 17+. The app fetches Bible verses from `bible-api.com`, displays them with styled typography, and lets users save favorites and share verses as images.

**Layers:**
- **Models/** — `BibleResponse` and `VerseEntry` (Codable, maps from `bible-api.com` JSON with snake_case coding keys) + `FavoriteVerse` (SwiftData `@Model`)
- **Services/** — Stateless structs with static async methods. `BibleAPIClient` wraps URLSession calls; `DailyVerseService` caches the daily verse in UserDefaults
- **ViewModels/** — All use `@Observable` macro (not `ObservableObject`). One per screen. Favorites data is fetched via `@Query` in the view; `FavoritesViewModel` handles mutations only
- **Views/** — SwiftUI views organized by screen, plus `Shared/` for reusable components (`VerseCardView`, `VerseShareView`, `LoadingView`, `ErrorView`)
- **Theme/** — `AppTheme` centralizes all design tokens (colors, fonts, spacing, shadows). `Color+Extensions` provides `init(hex:)` and `init(light:dark:)` for adaptive colors

**Navigation:** `MainTabView` is the root with 5 tabs: Today (daily verse), Discover (random), Search, Favorites, Settings. Search/Favorites/Settings each wrap content in `NavigationStack`.

**Persistence:**
- SwiftData `ModelContainer` for `FavoriteVerse`, configured in `Bible_AppApp.swift` and injected via `.modelContainer()`
- `@AppStorage` for user preferences (translation, appearance, font size, verse numbers)
- UserDefaults JSON for daily verse cache and recent search history

**API:** Base URL `https://bible-api.com`. Verse lookup: `GET /{reference}?translation={id}`. Random: `GET /?random=verse&translation={id}`. Translations: `web`, `kjv`, `bbe`, `oeb-us`.

**Sharing:** `VerseShareView` renders a 1080×1080 image via `ImageRenderer`, presented through a UIActivityViewController bridge in `View+ShareSheet`.

## Key Conventions

- `@Observable` macro for all ViewModels — do not use `ObservableObject`/`@Published`
- All networking is `async/await` with structured error handling via `BibleAPIError` enum
- Theme tokens from `AppTheme` (e.g. `AppTheme.Colors.accentGold`, `AppTheme.Fonts.verseText(size:)`, `AppTheme.Spacing.cardPadding`) — do not hardcode colors, fonts, or spacing
- Adaptive light/dark colors defined via `Color(light:dark:)` extension
- Test framework is Swift Testing (`@Test`, `#expect`) — not XCTest
- See `AGENTS.md` for detailed data model diagrams, view hierarchy, and full API reference

## Current Work in Progress

**Uncommitted changes** (Search screen refactor):
- **`SearchViewModel.swift`** — State transitions (`isLoading`, `result`, `errorMessage`, `clearSearch`) are now wrapped in `withAnimation(.easeInOut)` calls so animations are driven from the ViewModel instead of via `.animation()` modifiers on the view
- **`SearchView.swift`** — Extracted result display into a separate `SearchResultContentView` (private struct) to narrow the `@Observable` observation scope and prevent NavigationStack layout feedback loops. Removed `.animation()` view modifiers that caused those loops. Uses `@Bindable var viewModel` in `body`

**Recent commit history:**
- `dff7a4c` — chore(settings): update settings view logic
- `22e9bef` — feat(ui): add swipe to delete for favorites
- `e910351` — feat(settings): enhance settings flow
- `bdf85dc` — docs: update agents guide with skill system info
- `2aa1e90` — feat(app): implement core features (verse display, search, favorites, daily verse)
- `a446037` — feat: scaffold app architecture and project structure
- `1aebc25` — Initial Commit
