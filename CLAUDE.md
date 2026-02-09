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
- **Models/** — `BibleResponse` and `VerseEntry` (Codable, maps from `bible-api.com` JSON with snake_case coding keys) + `FavoriteVerse` (SwiftData `@Model`) + `VerseCategory` (mood-based categories: peace, strength, hope, wisdom, comfort, love)
- **Services/** — Stateless structs with static async methods. `BibleAPIClient` wraps URLSession calls; `DailyVerseService` caches the daily verse in UserDefaults; `NotificationService` manages local daily verse reminders
- **ViewModels/** — All use `@Observable` macro (not `ObservableObject`). One per screen. Favorites data is fetched via `@Query` in the view; `FavoritesViewModel` handles mutations only. `CategoryVerseViewModel` manages mood-based verse browsing. `SettingsViewModel` manages app preferences and notification scheduling.
- **Views/** — SwiftUI views organized by screen, plus `Shared/` for reusable components (`VerseCardView`, `VerseShareView`, `LoadingView`, `ErrorView`, `SwipeToDeleteModifier`). `Discover/` folder contains mood-based category browsing (`DiscoverView`, `CategoryGridView`, `CategoryVerseView`).
- **Theme/** — `AppTheme` centralizes all design tokens (colors, fonts, spacing, shadows). `Color+Extensions` provides `init(hex:)` and `init(light:dark:)` for adaptive colors

**Navigation:** `MainTabView` is the root with 5 tabs: Today (daily verse), Discover (mood-based categories + random), Search, Favorites, Settings. Search/Favorites/Settings each wrap content in `NavigationStack`.

**Persistence:**
- SwiftData `ModelContainer` for `FavoriteVerse`, configured in `Bible_AppApp.swift` and injected via `.modelContainer()`
- `@AppStorage` for user preferences (translation, appearance, font size, verse numbers, notification enabled/time)
- UserDefaults JSON for daily verse cache and recent search history

**API:** Base URL `https://bible-api.com`. Verse lookup: `GET /{reference}?translation={id}`. Random: `GET /?random=verse&translation={id}`. Translations: `web`, `kjv`, `bbe`, `oeb-us`. Mood-based categories use `VerseCategory.allCategories` (hardcoded with 10 categories: comfort, peace, hope, courage, love, strength, anxiety, gratitude, wisdom, forgiveness) and fetch verses via the standard verse lookup API.

**Sharing:** `VerseShareView` renders a 1080×1080 image via `ImageRenderer`, presented through a UIActivityViewController bridge in `View+ShareSheet`.

**Notifications:** `NotificationService` manages daily verse reminder notifications using `UNUserNotificationCenter`. Users can enable/disable and schedule reminder time in Settings.

## Key Conventions

- `@Observable` macro for all ViewModels — do not use `ObservableObject`/`@Published`
- All networking is `async/await` with structured error handling via `BibleAPIError` enum
- Theme tokens from `AppTheme` (e.g. `AppTheme.Colors.accentGold`, `AppTheme.Fonts.verseText(size:)`, `AppTheme.Spacing.cardPadding`) — do not hardcode colors, fonts, or spacing
- Adaptive light/dark colors defined via `Color(light:dark:)` extension
- Test framework is Swift Testing (`@Test`, `#expect`) — not XCTest
- See `AGENTS.md` for detailed data model diagrams, view hierarchy, and full API reference

## Current Work in Progress

**Uncommitted changes:** None — all work is committed.

**Recent commit history:**
- `39f2264` — refactor(ui): restructure settings panel and main navigation flow
- `c5bde39` — Merge pull request #2 from mmeister86/feature/daily-notifications
- `ce26f19` — feat(notifications): add daily verse reminder notifications
- `9540580` — docs: expand discover feature description
- `aed3e9f` — Merge pull request #1 from mmeister86/feature/mood-categories
- `de30ae9` — feat(discover): add mood-based verse categories
- `3033455` — chore(ui): update verse share view
- `732d964` — docs: add project README
- `6876a6b` — fix(search): stabilize search animations
- `dff7a4c` — chore(settings): update settings view logic
- `22e9bef` — feat(ui): add swipe to delete for favorites
- `e910351` — feat(settings): enhance settings flow
- `bdf85dc` — docs: update agents guide with skill system info
- `2aa1e90` — feat(app): implement core features (verse display, search, favorites, daily verse)
- `a446037` — feat: scaffold app architecture and project structure
- `1aebc25` — Initial Commit
