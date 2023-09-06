//
//  Pet_SwiftData.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import Foundation
import SwiftData

/// Pet Identity used with SwiftData to create a persistent data model.
@Model
final class Pet_Identity {
    /// Name of pet.
    var name: String = "\(Int.random(in: 1..<1000))"
    /// Personality of pet.
    var personality: Pet_Personality = Pet_Personality(mind: 0, nature: 0, energy: 0)
    /// Birth date of pet.
    var birthDate: Date = Date()
    
    init(name: String, personality: Pet_Personality, birthDate: Date) {
        self.name = name
        self.personality = personality
        self.birthDate = birthDate
    }
}

/// Defines the personality of a pet.
struct Pet_Personality : Codable {
    /// Describes how introverted or extroverted a pet is. 
    var mind : Int8
    /// Describes how mellow or aggressive a pet is.
    var nature : Int8
    /// Describes how cautious or impulsive a pet is.
    var energy : Int8
}
