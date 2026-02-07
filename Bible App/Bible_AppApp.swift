//
//  Bible_AppApp.swift
//  Bible App
//
//  Created by Matthias Meister on 07.02.26.
//

import SwiftUI
import SwiftData

@main
struct Bible_AppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoriteVerse.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Fallback to in-memory container for graceful degradation
            print("Warning: Could not create persistent ModelContainer, falling back to in-memory: \(error)")
            return try! ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
