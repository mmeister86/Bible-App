//
//  MainTabView.swift
//  Bible App
//

import SwiftUI

/// Root TabView with 5 tabs: Today, Discover, Search, Favorites, Settings.
struct MainTabView: View {

    var body: some View {
        TabView {
            DailyVerseView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }

            DiscoverView()
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
    }
}

#Preview {
    MainTabView()
}
