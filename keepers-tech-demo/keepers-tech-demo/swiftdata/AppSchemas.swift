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
    typealias Latest = V2
    
    enum V2: VersionedSchema {
        static var versionIdentifier: Schema.Version = Schema.Version(0, 0, 2)
        static var models: [any PersistentModel.Type] {
            [Creature.Backing.self]
        }
    }
    
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

        struct V1toV2Light {
            static let migration: MigrationStage =
                .lightweight(
                    fromVersion: AppSchema.V1.self,
                    toVersion: AppSchema.V2.self)
        }
        
        struct V0toV1NoOp {
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
