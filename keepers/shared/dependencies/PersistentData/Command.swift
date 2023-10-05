//
//  PetCommand.swift
//  keepers
//
//  Created by Hung on 10/2/23.
//

import Foundation
import SwiftData

typealias Command = AppSchema.V1.Command

extension AppSchema.V1 {
    @Model
    final class Command {
        var timestamp: Date = Date.now
        var action: Action = Action.noop
        var pet: PetIdentity?

        init(timestamp: Date, action: Action, pet: PetIdentity) {
            self.timestamp = timestamp
            self.action = action
            self.pet = pet
        }
        
        enum Action: Codable, Equatable {
            case noop
            case hatch
            case feed(Double)
            case play
            case unalive
        }
    }
    
}
