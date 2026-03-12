//
//  MainTabView.swift
//  Bible App
//

import SwiftUI

/// Root TabView with 5 tabs: Today, Discover, Search, Favorites, Settings.
struct MainTabView: View {

    enum Tab: Int {
        case today, discover, search, favorites, settings

        init(destination: QuickActionDestination) {
            switch destination {
            case .today: self = .today
            case .discover: self = .discover
            case .search: self = .search
            case .favorites: self = .favorites
            }
        }
    }

    @ObservedObject private var quickActionCenter = QuickActionCenter.shared
    @State private var selectedTab: Tab

    init() {
        let initialDestination = QuickActionCenter.shared.consumeInitialDestination()
        _selectedTab = State(initialValue: Tab(destination: initialDestination))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DailyVerseView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(Tab.today)

            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "shuffle")
                }
                .tag(Tab.discover)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(Tab.favorites)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(Color.accentGold)
        .onReceive(NotificationCenter.default.publisher(for: .didTapDailyVerseNotification)) { _ in
            selectedTab = .today
        }
        .onReceive(quickActionCenter.$requestedDestination) { destination in
            guard let destination else {
                return
            }

            selectedTab = Tab(destination: destination)
            quickActionCenter.consumeCurrentRequest()
        }
    }
}

#Preview {
    MainTabView()
}
