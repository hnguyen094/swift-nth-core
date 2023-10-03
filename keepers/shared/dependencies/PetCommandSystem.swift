//
//  PetCommandSystem.swift
//  keepers
//
//  Created by Hung on 10/2/23.
//

import Foundation
import Dependencies

extension DependencyValues {
    
}

struct PetCommandSystem {
    struct PetStartIdentity {
        let personality: [Int]
        let birthDate: Date
        
        let seed: Int64
    }
    
    struct PetState {
        let hatched: Bool
        let lastFed: Date
    }
    
    enum State {
        case egg
        case alive
        case dead
    }
    
    
    struct Command {
        let timestamp: Date
        let command: CommandType
        
        enum CommandType {
            case hatch
            case feed
            case play
            case death
        }
    }
    
    var state: State
    mutating func exec(_ commands: [Command], upTo date: Date = .now) {
        for cmd in commands {
            if cmd.timestamp > date {
                break
            }
            switch cmd.command {
            case .hatch:
                state = .alive
                break
            case .death:
                state = .dead
                break
            default:
                state = .alive
            }
        }
    }
}
