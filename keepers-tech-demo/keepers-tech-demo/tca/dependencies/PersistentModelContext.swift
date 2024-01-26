//
//  PersistentModelContext.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Backed Data Storage System.

import Dependencies
import SwiftData

extension DependencyValues {
    var modelContext: PersistentModelContext {
        get { self[PersistentModelContext.self] }
        set { self[PersistentModelContext.self] = newValue }
    }
}

@ModelActor
actor PersistentModelContext {
    func enableAutosave() {
        modelContext.autosaveEnabled = true
    }
    
    func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
        return try modelContext.fetch(descriptor)
    }
    
    func fetch<T: PersistentModel>() throws -> [T] { // TODO: a convenience function?
        return try modelContext.fetch(FetchDescriptor<T>())
    }
    
    func insert<T>(_ models: [T]) where T : PersistentModel {
        for model in models {
            modelContext.insert(model)
        }
    }
    
    func delete<T>(_ models: [T]) where T : PersistentModel {
        for model in models {
            modelContext.delete(model)
        }
    }
    
    func save() throws {
        try modelContext.save()
    }
    
    /// A catch all to run any closure on this actor's `ModelContext`, and should be converted to a
    /// light wrapper if used often.
    func run(_ action: (ModelContext) -> Void) {
        action(modelContext)
    }
}

extension PersistentModelContext: DependencyKey {
    static let liveValue = PersistentModelContext(
        modelContainer: createContainer(from: liveConfig)) // TODO: change back to live
    static let previewValue = PersistentModelContext(
        modelContainer: createContainer(from: ephemeralConfig))
    
    /// The types that are stored in the data model that fully describes the state of the application.
    private static let schema = Schema(versionedSchema: AppSchema.Latest.self)
    
    private static let liveConfig = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .automatic
    )

    private static let localConfig = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .none
    )
    
    private static let ephemeralConfig = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true,
        allowsSave: false,
        groupContainer: .none,
        cloudKitDatabase: .none
    )
    
    /// Creates a model container for use with CloudKit.
    private static func createContainer(from config: ModelConfiguration) -> ModelContainer {
        return try! ModelContainer(
            for: schema,
            migrationPlan: AppSchema.AppMigrationPlan.self,
            configurations: [config])
    }
}
