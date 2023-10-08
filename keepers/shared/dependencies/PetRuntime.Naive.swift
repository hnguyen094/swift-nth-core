//
//  PetRuntime.Naive.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//
//  Naive implementation of a functional pet runtime.

import Foundation
// import SwiftPriorityQueue

extension PetRuntime {
    /// We love naive implementations!
    ///
    /// - ToDo: RNG (how do we propagate cleanly? Do we need a struct to combine multiple dependencies?)
    /// - ToDo: corruption handling! An external user can see corrupted state, but we probably want to handle
    /// cases we can predict ourselves (for some reason.)
    /// - ToDo: Performant and predictable caching behavior! I'd imagine it's expensive for if _every frame_ we
    /// have to re-observe and recompute the entire pet state. It feels like it should be easy to cache with
    /// something else calling this. \
    /// Note that the Stateful version of this runtime should also query the model context dependency
    /// correctly
    /// - ToDo: For cases where we don't observe every frame (which honestly, is lazy) we could be in a situation
    /// where the pet has died but the screen hasn't displayed it. During this window, if the user does something
    /// to the pet, the action would queue _after_ death but to the user this is _before_. Seems bad and
    /// should be avoided at all costs.
    /// - ToDo: Time RNG! Do we have any variables that requires RNG but should be continuous? For example,
    /// the physical location of a pet over time? If we do, we would want to implement 1D perlin noise or
    /// some non-periodic function that is stable between commands (relative to birth date, or something.)
    enum Naive {
        static func observe(pet: PetIdentity, upTo date: Date = .now) -> State {
            var computedState = State.egg
            var previousTimestamp = pet.birthDate

            for command in pet.userInputs! {
                let currentTimestamp = command.timestamp > date ? date : command.timestamp
                let interval = currentTimestamp.timeIntervalSince(previousTimestamp)
                previousTimestamp = currentTimestamp

                computedState = transition(computedState, forward: interval)
                
                if (command.timestamp <= date) {
                    computedState = transition(computedState, with: command)
                }
            }
            return computedState
        }

        static func submit(pet: PetIdentity, action: Command.Action, at date: Date) {
            pet.userInputs!.append(Command(
                timestamp: date,
                action: action,
                pet: pet))
            // TODO: add/change death cmd timestamp
            pet.userInputs!.sort()
        }
        
        private static func transition(_ state: State, with command: Command) -> State {
            switch state {
            case .egg where command.action == .hatch:
                .alive(transition(alive: AliveState(), with: command.action))
            case .alive(_) where command.action == .unalive:
                .dead
            case .alive(let aliveState) where command.action != .hatch:
                .alive(transition(alive: aliveState, with: command.action))
            case .egg, .alive, .dead, .corrupted:
                .corrupted
            }
        }
        
        private static func transition(_ state: State, forward time: TimeInterval) -> State {
            switch state {
            case .alive(let aliveState):
                .alive(transition(alive: aliveState, forward: time))
            case .egg, .dead, .corrupted:
                state
            }
        }
        
        private static func transition(alive: AliveState, with action: Command.Action) -> AliveState {
            var state = alive
            switch action {
            case .feed(let amount):
                state.fullness = (state.fullness + amount).clamped(to: 0...1)
            case .play:
                state.happiness = (state.happiness + 0.1).clamped(to: 0...1)
            case .hatch, .unalive, .noop:
                break
            }
            return state
        }
        
        private static func transition(alive: AliveState, forward time: TimeInterval) -> AliveState {
            var state = alive
            let minutes = Double(time.minutes)
            state.fullness = (state.fullness - minutes / 600).clamped(to: 0...1)
            state.happiness = (state.happiness - minutes / 1800).clamped(to: 0...1)
            return state
        }
    }
}
