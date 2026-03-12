//
//  DailyVerse_WatchAppApp.swift
//  DailyVerse WatchApp Watch App
//
//  Created by Matthias Meister on 07.03.26.
//

import SwiftUI

enum WatchAppearanceMode: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

@main
struct DailyVerse_WatchApp_Watch_AppApp: App {
    @AppStorage("appearanceMode") private var appearanceModeRawValue: Int = WatchAppearanceMode.system.rawValue

    init() {
        WatchConnectivityManager.shared.activate()
    }

    private var preferredColorScheme: ColorScheme? {
        WatchAppearanceMode(rawValue: appearanceModeRawValue)?.colorScheme
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color("AccentColor"))
                .preferredColorScheme(preferredColorScheme)
        }
    }
}
