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
    @Dependency(\.logger) var logger

    var state: State? = nil // should be get-only
    var pet: PetIdentity? = nil // should be get-only

    mutating func load(_ pet: PetIdentity, upTo date: Date = .now) {
        if (self.pet != nil) {
            // TODO: unload old pet here.
        }
        self.pet = pet
        self.state = .egg
        pet.userInputs = pet.userInputs ?? []
        for command in pet.userInputs! {
            if command.timestamp > date {
                // pause execution. There might be other events scheduled after.
                // TODO: something should probably be handled here.
                break
            }
            Self.exec(into: &self.state!, command: command)
            if case .corrupted = self.state {
                logger.error("""
                    Pet state is corrupted; unexpected command \
                    \(String(describing: command.action))
                    """)
                // TODO: do something to recover in each situation
                break // probably, right?! we can't transition corrupt state anw
            }
        }

    }

    func send(command: Command) {
        // find where I should insert (that is, was this action "too late"?)
        // maybe there could be weirdness here -- what if the pet is dead 5s ago, but the update loop checks every 15?
        // maybe we don't recompute here and just assume pet is still alive.

        // also, we should refactor the switch case out to use in here too.
    }

    // what do we return from this function??? Specifically, which state?
    func observe(at date: Date = .now) {
        guard case let .alive(aliveState) = state else {
            // TODO: return something
            return
        }
        let delta = date.timeIntervalSince(aliveState.lastUpdated)
        
        // TODO: return something useful
    }
    
    // given a command, transform the current state into the next. Use
    // whatever is necessary.
    static func exec(into state: inout State, command: Command) {
        switch state {
        case .egg where command.action == .hatch:
            state = .alive(AliveState(fullness: 1, happiness: 1, lastUpdated: command.timestamp))
        case .alive(var aliveState) where command.action != .hatch:
            if case .unalive = command.action {
                state = .dead
                break
            }
            Self.exec(into: &aliveState, command: command)
            state = .alive(aliveState)
            
        case .corrupted: // these states cannot transition
            return
        case .egg, .alive, .dead:
            state = .corrupted
        }
    }
    
    static func exec(into state: inout AliveState, command: Command) {
        state.lastUpdated = command.timestamp
        switch command.action {
        case .feed(let amount):
            state.fullness = (state.fullness + amount).clamped(to: -1...1)
        case .play:
            state.happiness = (state.happiness + 0.1).clamped(to: -1...1)
        case .hatch, .unalive, .noop:
            break
        }
    }
    
    func project(state: AliveState, forwardTo date: Date) -> AliveState {
        
    }
    
    struct AliveState: Equatable {
        var fullness: Double
        var happiness: Double
        
        var lastUpdated: Date
        // TODO: add more computed variables as discussed
    }
    
    enum State {
        case egg
        case alive(AliveState)
        case dead
        
        case corrupted
    }
}

extension PetRuntime: DependencyKey {
    static var liveValue: Self {
        return Self()
    }
}
