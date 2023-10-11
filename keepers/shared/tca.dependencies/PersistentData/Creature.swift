//
//  Creature.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import Foundation
import SwiftData

typealias Creature = AppSchema.V1.Creature
typealias Personality = AppSchema.V1.Personality
typealias Species = AppSchema.V1.Species

extension AppSchema.V1 {
    /// Pet Identity used with SwiftData to create a persistent data model.
    @Model
    final class Creature {
        /// Name of pet.
        var name: String = ""
        /// Personality of pet.
        var personality: Personality = Personality()
        /// Birth date of pet.
        var birthDate: Date = Date.now
        /// Species of pet.
        var species: Species = Species.missingno
        
        /// The random seed used for pseudo-random behavior and events.
        var seed: UInt64 = 0
        /// The entire list of all the things that this pet has & will experience with no additional user inputs.
        @Relationship(deleteRule: .cascade, inverse: \Record.pet)
        var records: [Record]? = [Record]()
        
        init() {}
        
        static var test: Self {
            let pet = Self.init()
            pet.name = "Test"
            pet.records = []
            return pet
        }
    }
    
    /// Defines the species of a pet.
    enum Species : Codable, CaseIterable, Equatable {
        case missingno
        case penguin
        case frog
        case snake
    }

    /// Defines the personality of a pet.
    struct Personality : Codable, Equatable {
        /// Describes how introverted or extroverted a pet is.
        var mind : Int8 = 0
        /// Describes how mellow or aggressive a pet is.
        var nature : Int8 = 0
        /// Describes how cautious or impulsive a pet is.
        var energy : Int8 = 0
    }
}
