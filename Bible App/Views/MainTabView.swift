//
//  MainTabView.swift
//  Bible App
//

import SwiftUI

/// Root TabView with 5 tabs: Today, Discover, Search, Favorites, Settings.
/// Applies the user's chosen appearance mode and accent color.
struct MainTabView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    var body: some View {
        TabView {
            DailyVerseView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            RandomVerseView()
                .tabItem {
                    Label("Discover", systemImage: "shuffle")
                }

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.accentGold)
        .preferredColorScheme(colorScheme)
    }

    /// Map the stored appearance mode string to a ColorScheme value.
    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil // system default
        }
    }
}

#Preview {
    MainTabView()
}
