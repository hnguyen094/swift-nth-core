//
//  PetRuntime.swift
//  keepers
//
//  Created by Hung on 10/2/23.
//
//  Pet runtime system.

import Foundation
import Dependencies

extension DependencyValues {
    var petRuntime: PetRuntime {
        get { self[PetRuntime.self] }
        set { self[PetRuntime.self] = newValue }
    }
}

/// turns a `PetIdentity` into a deterministic runtime state for 
/// a given point in time.
struct PetRuntime {
    var state: State? = nil // should be get-only
    var pet: PetIdentity? = nil // should be get-only

    var load: (_ pet: PetIdentity, upTo date: Date = .now)
    var insert: (command: Command)

    struct AliveState {
        let fullness: Double
        let happiness: Double
        // TODO: add more computed variables as discussed
    }
    
    enum State {
        case egg
        case alive(AliveState)
        case dead
    }
}

extension PetRuntime: DependencyKey {
    static var liveValue: Self {
        return unimplemented
    }

    static let naive = Self(
        load: { pet, currentDate in 
            self.pet = pet
            if pet.userInputs ?= []
            for cmd in pet.userInputs {
                if cmd.timestamp > currentDate {
                    break
                }
                // compute time since last action
                // maybe we don't do that here?
                switch cmd.command {
                case .noop:
                    // logs a warning.
                    break
                case .hatch:
                    let state = AliveState(
                        fullness: 0,
                        happiness: 0
                    )
                    self.state = .alive(state)
                    break
                case .feed(let amount):
                    // takes current aliveState and increase fullness
                    break
                case .play:
                    // takes current aliveState and increase happiness
                    break
                case .unalive:
                    state = .dead
                    break
                default:
                    state = .alive
                }
            }
        },
        insert: { newCommand in 
            // find where I should insert (that is, was this action "too late"?)
            // maybe there could be weirdness here -- what if the pet is dead 5s ago, but the update loop checks every 15?
            // maybe we don't recompute here and just assume pet is still alive.
            
            // also, we should refactor the switch case out to use in here too.
        }
    )

    static let unimplemented = Self(
        load: { _, _ in unimplemented("PetRuntime.load") },
        insert: { _ in unimplemented("PetRuntime.update") }
    )
}