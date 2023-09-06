//
//  mainApp.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import SwiftData

@main
struct mainApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet_Identity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // FetchProgressView()
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
