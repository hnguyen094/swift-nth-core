//
//  mainApp.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import SwiftData

// @main
struct mainApp_deprecated: App {
    private let sharedModelContainer: ModelContainer
    
    init() {
        do {
            sharedModelContainer = try Shared.createModelContainer()
        } catch {
            fatalError("Failed to load the model container. \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
