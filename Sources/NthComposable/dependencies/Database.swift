//
//  Database.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Backed Data Storage System.

import Dependencies
import DependenciesMacros
import SwiftData

extension DependencyValues {
    public var database: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

@DependencyClient
public struct Database {
    public var initialize: (
        Configuration,
        _ for: VersionedSchema.Type,
        _ migrationPlan: SchemaMigrationPlan.Type) throws 
    -> Void
    
    public var modelActor: () -> DataHandler?
}

extension Database: DependencyKey {
    public static var testValue: Self = .init()
    public static var previewValue: Self = .init()
    public static var liveValue: Self {
        var handler: DataHandler? = .none
        return .init(
            initialize: { config, versionedSchema, migrationPlan in
                let schema = Schema(versionedSchema: versionedSchema)
                let modelConfiguration: ModelConfiguration = switch config {
                case .cloud: .init(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .automatic)
                case .local: .init(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none)
                case .ephemeral: .init(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    allowsSave: false,
                    groupContainer: .none,
                    cloudKitDatabase: .none)
                }
                handler = .init(modelContainer: try .init(
                    for: schema,
                    migrationPlan: migrationPlan,
                    configurations: [modelConfiguration] ))
            }, 
            modelActor: { handler })
    }
    
    public enum Configuration {
        case cloud
        case local
        case ephemeral
    }
}

extension Database {
    @ModelActor
    public actor DataHandler {
        public func enableAutosave() {
            modelContext.autosaveEnabled = true
        }
        
        public func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
            return try modelContext.fetch(descriptor)
        }
        
        public func fetch<T: PersistentModel>() throws -> [T] { // TODO: a convenience function?
            return try modelContext.fetch(FetchDescriptor<T>())
        }
        
        public func insert<T>(_ models: [T]) where T : PersistentModel {
            for model in models {
                modelContext.insert(model)
            }
        }
        
        public func delete<T>(_ models: [T]) where T : PersistentModel {
            for model in models {
                modelContext.delete(model)
            }
        }
        
        public func save() throws {
            try modelContext.save()
        }
    }
}
