//
//  PetIdentity.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import Foundation
import SwiftData

typealias PetIdentity = AppSchema.V2.PetIdentity
typealias PetPersonality = AppSchema.V2.PetPersonality

extension AppSchema.V2 {
    typealias PetPersonality = AppSchema.V1.PetPersonality
    /// Pet Identity used with SwiftData to create a persistent data model.
    @Model
    final class PetIdentity {
        /// Name of pet.
        var name: String = "\(Int.random(in: 1..<1000))"
        /// Personality of pet.
        var personality: PetPersonality = PetPersonality()
        /// Birth date of pet.
        var birthDate: Date = Date()
        
        init() { }
        
        init(name: String, personality: PetPersonality, birthDate: Date) {
            self.name = name
            self.personality = personality
            self.birthDate = birthDate
        }
    }
}

extension AppSchema.V1 {
    @Model
    final class Pet_Identity {
        /// Name of pet.
        var name: String = "\(Int.random(in: 1..<1000))"
        /// Personality of pet.
        var personality: PetPersonality = PetPersonality()
        /// Birth date of pet.
        var birthDate: Date = Date()
        
        init() { }
        
        init(name: String, personality: PetPersonality, birthDate: Date) {
            self.name = name
            self.personality = personality
            self.birthDate = birthDate
        }
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
