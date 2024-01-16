//
//  AppSchemas.swift
//  keepers
//
//  Created by Hung on 9/11/23.
//

import Foundation
import SwiftData
import Dependencies

/// Provides the App Data Schemas between releases. We will accept data corruption during development.
enum AppSchema {
    typealias Latest = V1
    
    enum V1: VersionedSchema {
        static var versionIdentifier: Schema.Version = Schema.Version(0, 0, 1)
        static var models: [any PersistentModel.Type] {
            [Creature.Backing.self]
        }
    }
    
    enum V0: VersionedSchema {
        static var versionIdentifier: Schema.Version = Schema.Version(0, 0, 0)
        static var models: [any PersistentModel.Type] {
            []
        }
    }
}

extension AppSchema {
    enum AppMigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            [AppSchema.V0.self, AppSchema.V1.self]
        }
        
        static var stages: [MigrationStage] {
            [V0toV1NoOp.migration]
        }

        struct V0toV1NoOp {
            @Dependency(\.logger) var logger
            
            static let migration: MigrationStage =
                MigrationStage.custom(
                    fromVersion: AppSchema.V0.self,
                    toVersion: AppSchema.V1.self,
                    willMigrate: Self.willMigrate(_:),
                    didMigrate: Self.didMigrate(_:))
            
            static func willMigrate(_ context: ModelContext) { }
            
            static func didMigrate(_ context: ModelContext) { }
        }
    }
}
