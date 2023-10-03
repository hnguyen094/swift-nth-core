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
            [PetIdentity.self, Command.self]
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
            [V0toV1NoOp().migration]
        }

        class V0toV1NoOp {
            @Dependency(\.logger) var logger
            
            var migration: MigrationStage {
                return MigrationStage.custom(
                    fromVersion: AppSchema.V0.self,
                    toVersion: AppSchema.V1.self,
                    willMigrate: self.willMigrate(_:),
                    didMigrate: self.didMigrate(_:))
            }
            
            func willMigrate(_ context: ModelContext) { }
            
            func didMigrate(_ context: ModelContext) { }
        }
    }
}
