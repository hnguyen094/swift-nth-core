//
//  PersistentModelActor.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Backed Data Storage System.

import Dependencies
import SwiftData

extension DependencyValues {
    var modelContextActor: PersistentModelActor {
        get { self[PersistentModelActor.self] }
        set { self[PersistentModelActor.self] = newValue }
    }
}

@ModelActor
actor PersistentModelActor {
    func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
        return try modelContext.fetch(descriptor)
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

extension PersistentModelActor: DependencyKey {
    static let liveValue = PersistentModelActor(
        modelContainer: createContainer(from: liveConfig))
    static let previewValue = PersistentModelActor(
        modelContainer: createContainer(from: ephemeralConfig))
    
    /// The types that are stored in the data model that fully describes the state of the application.
    private static var schema = Schema([
        PetIdentity.self
    ])
    
    private static let liveConfig = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .automatic
    )
    
    private static let ephemeralConfig = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true,
        cloudKitDatabase: .none
    )
    
    /// Creates a model container for use with CloudKit.
    private static func createContainer(from config: ModelConfiguration) -> ModelContainer {
        @Dependency(\.logger) var logger
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: AppSchema.AppMigrationPlan.self,
                configurations: [config])
        } catch {
            logger.error("Failed to load the model container. \(error)")
        }
        return try! ModelContainer(for: PetIdentity.self)
    }
}
