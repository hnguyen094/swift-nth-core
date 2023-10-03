//
//  PetIdentity.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import Foundation
import SwiftData

typealias PetIdentity = AppSchema.V1.PetIdentity
typealias PetPersonality = AppSchema.V1.PetPersonality
typealias PetSpecies = AppSchema.V1.PetSpecies

extension AppSchema.V1 {
    /// Pet Identity used with SwiftData to create a persistent data model.
    @Model
    final class PetIdentity {
        /// Name of pet.
        var name: String = ""
        /// Personality of pet.
        var personality: PetPersonality = PetPersonality()
        /// Birth date of pet.
        var birthDate: Date = Date.now
        /// Species of pet.
        var species: PetSpecies = PetSpecies.missingno
        
        /// The random seed used for pseudo-random behavior and events.
        var seed: Int64 = 0
        /// The entire list of all the things that this pet has & will experience with no additional user inputs.
        @Relationship(deleteRule: .cascade, inverse: \Command.pet)
        var userInputs: [Command]?
        
        init() {}
        
//        init(name: String, personality: PetPersonality, birthDate: Date, species: PetSpecies, seed: Int64, userInputs: [Command]) {
//            self.name = name
//            self.personality = personality
//            self.birthDate = birthDate
//            self.species = species
//            self.seed = seed
//            self.userInputs = userInputs
//        }
        
        static var test: Self {
            let pet = Self.init()
            pet.name = "Test"
            pet.userInputs = []
            return pet
        }
    }
    
    /// Defines the species of a pet.
    enum PetSpecies : Codable, CaseIterable, Equatable {
        case missingno
        case penguin
        case frog
        case snake
    }

    /// Defines the personality of a pet.
    struct PetPersonality : Codable, Equatable {
        /// Describes how introverted or extroverted a pet is.
        var mind : Int8 = 0
        /// Describes how mellow or aggressive a pet is.
        var nature : Int8 = 0
        /// Describes how cautious or impulsive a pet is.
        var energy : Int8 = 0
    }
}
