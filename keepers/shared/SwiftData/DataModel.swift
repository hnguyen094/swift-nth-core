//
//  DataModel.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftData

/// A struct that contains shared functions across targets.
struct Shared {
    /// The types that are stored in the data model that fully describes the state of the application.
    private static var schema = Schema([
        Pet_Identity.self
    ])
    
    /// Creates a model container for use with CloudKit.
    static func createModelContainer() throws -> ModelContainer {
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic)
        
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
    
}
