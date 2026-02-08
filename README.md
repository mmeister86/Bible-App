# Bible App

A beautifully crafted iOS app for reading, discovering, and saving Bible verses — built entirely with SwiftUI and modern Apple frameworks.

## Features

**Daily Verse** — Start each day with an inspiring verse of the day, presented on an elegantly designed full-screen card with smooth spring animations.

**Discover** — Tap to receive a random verse from Scripture. A simple way to explore passages you might never have found on your own.

**Search** — Look up any Bible reference (e.g. *John 3:16*, *Romans 8:28-30*) across multiple translations and see results with refined serif typography and inline verse numbers.

**Favorites** — Save the verses that resonate with you. Swipe to remove, browse anytime — all persisted locally with SwiftData.

**Share as Image** — Share any verse as a beautifully rendered 1080x1080 image card with gradient background, perfect for social media and messaging.

**Settings** — Choose your preferred Bible translation, toggle light/dark/system appearance, adjust font size with a live preview, and show or hide verse numbers.

## Translations

| ID | Translation |
|---|---|
| `web` | World English Bible |
| `kjv` | King James Version |
| `bbe` | Bible in Basic English |
| `oeb-us` | Open English Bible (US) |

## Architecture

The app follows **MVVM** with a clear separation of concerns:

```
Bible App/
├── Models/          Codable API models + SwiftData @Model
├── Services/        Stateless API client & daily verse cache
├── ViewModels/      @Observable view models (one per screen)
├── Views/
│   ├── DailyVerse/  Verse of the day screen
│   ├── RandomVerse/ Discover screen
│   ├── Search/      Verse lookup
│   ├── Favorites/   Saved verses list
│   ├── Settings/    Preferences
│   └── Shared/      VerseCardView, VerseShareView, LoadingView, ErrorView
├── Theme/           Design tokens (colors, fonts, spacing, shadows)
└── Extensions/      Share sheet bridge, string helpers
```

**Key decisions:**
- `@Observable` macro for all view models — no legacy `ObservableObject`
- Centralized design system via `AppTheme` with adaptive light/dark colors
- `async/await` networking with structured error handling
- SwiftData for favorites, `@AppStorage` for preferences, UserDefaults for caches
- Zero third-party dependencies — Apple frameworks only

## Requirements

- iOS 17.0+
- Xcode 15.0+
- No API key required — the app uses the free [bible-api.com](https://bible-api.com) API

## Getting Started

```bash
git clone https://github.com/mmeister86/Bible-App.git
cd Bible-App
open "Bible App.xcodeproj"
```

Select an iPhone simulator and hit **Run** (Cmd+R). That's it — no pods, no packages, no configuration needed.

## Build & Test

```bash
# Build
xcodebuild -scheme "Bible App" -destination "platform=iOS Simulator,name=iPhone 16" build

# Run tests
xcodebuild -scheme "Bible App" -destination "platform=iOS Simulator,name=iPhone 16" test
```

## API

All verse data comes from [bible-api.com](https://bible-api.com), a free and open Bible API.

| Endpoint | Description |
|---|---|
| `GET /{reference}?translation={id}` | Fetch a specific verse or passage |
| `GET /?random=verse&translation={id}` | Fetch a random verse |

## License

This project is open source. The Bible translations used (WEB, KJV, BBE, OEB) are all in the public domain.
