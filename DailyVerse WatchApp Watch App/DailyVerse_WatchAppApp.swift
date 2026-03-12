//
//  DailyVerse_WatchAppApp.swift
//  DailyVerse WatchApp Watch App
//
//  Created by Matthias Meister on 07.03.26.
//

import SwiftUI

@main
struct DailyVerse_WatchApp_Watch_AppApp: App {
    init() {
        WatchConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(Color("AccentColor"))
        }
    }
}
