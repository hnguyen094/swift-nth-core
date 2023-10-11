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
    final class Command: Comparable {
        var timestamp: Date = Date.now
        var action: Action = Action.noop
        var pet: PetIdentity?

        init(timestamp: Date, action: Action, pet: PetIdentity?) {
            self.timestamp = timestamp
            self.action = action
            self.pet = pet
        }
        
        static func < (lhs: Command, rhs: Command) -> Bool {
            lhs.timestamp < rhs.timestamp
        }
        
        enum Action: Codable, CaseIterable, Hashable {
            static var allCases: [AppSchema.V1.Command.Action] {
                [.noop, .hatch, .feed(0.1), .play, .unalive]
            } // TODO: probably a better way to do this
            
            case noop
            case hatch
            case feed(Double)
            case play
            case unalive
        }
    }
}
