//
//  AppSchemas.swift
//  keepers
//
//  Created by Hung on 9/11/23.
//

import Foundation
import SwiftData

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
            [migrateV1toV2Light]
        }
        
        static let migrateV1toV2Light = MigrationStage.lightweight(
            fromVersion: AppSchema.V1.self,
            toVersion: AppSchema.V2.self)
        
        static let migrateV1toV2 = MigrationStage.custom(
            fromVersion: AppSchema.V1.self,
            toVersion: AppSchema.V2.self,
            willMigrate: { context in
                let oldPets = try! context.fetch(
                    FetchDescriptor<AppSchema.V1.Pet_Identity>())
                print ("Migrating \(oldPets.count) old pet(s).")
                for oldPet in oldPets {
                    print("Trying to insert new pet from old pet (\(oldPet.name))")
                    let pet = AppSchema.V2.PetIdentity(
                        name: oldPet.name,
                        personality: oldPet.personality,
                        birthDate: oldPet.birthDate)
                    context.insert(pet)
                    context.delete(oldPet)
                }
                try? context.save()
            }, didMigrate: nil
        )
    }
}
