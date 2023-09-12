//
//  AppSchemas.swift
//  keepers
//
//  Created by Hung on 9/11/23.
//

import Foundation
import SwiftData
import Dependencies

enum AppSchema {
    enum V2: VersionedSchema {
        static var versionIdentifier: Schema.Version = Schema.Version(0, 0, 2)
        static var models: [any PersistentModel.Type] {
            [PetIdentity.self]
        }
    }
    enum V1: VersionedSchema {
        static var versionIdentifier: Schema.Version = Schema.Version(0, 0, 1)
        
        static var models: [any PersistentModel.Type] {
            [Pet_Identity.self]
        }
    }
}

extension AppSchema {
    enum AppMigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            [AppSchema.V1.self, AppSchema.V2.self]
        }
        
        static var stages: [MigrationStage] {
            [V1toV2().migration]
        }
                
        class V1toV2 {
            @Dependency(\.logger) var logger
            var oldPets: [AppSchema.V1.Pet_Identity] = []
            
            var migration: MigrationStage {
                return MigrationStage.custom(
                    fromVersion: AppSchema.V1.self,
                    toVersion: AppSchema.V2.self,
                    willMigrate: self.willMigrate(_:),
                    didMigrate: self.didMigrate(_:))
            }
            
            func willMigrate(_ context: ModelContext) {
                oldPets = try! context.fetch(
                    FetchDescriptor<AppSchema.V1.Pet_Identity>())
                for oldPet in oldPets {
                    context.delete(oldPet)
                    logger.info("Deleted pet (\(oldPet.name)) in migration.")
                }
                try? context.save()
            }
            
            func didMigrate(_ context: ModelContext) {
                for oldPet in oldPets {
                    let pet = AppSchema.V2.PetIdentity(
                        name: oldPet.name,
                        personality: oldPet.personality,
                        birthDate: oldPet.birthDate)
                    context.insert(pet)
                    logger.info("Migrated pet (\(pet.name)) in migration.")
                }
                try? context.save()
            }
        }
    }
}
