//
//  mainApp.swift
//  keepers:together
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import SwiftData

@main
struct mainApp: App {
    private let sharedModelContainer: ModelContainer
    
    init() {
        do {
            sharedModelContainer = try Shared.createModelContainer()
        } catch {
            fatalError("Failed to load the model container (maybe CloudKit configuration error?) \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .modelContainer(sharedModelContainer)
    }
}