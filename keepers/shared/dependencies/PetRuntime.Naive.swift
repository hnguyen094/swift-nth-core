//
//  PetRuntime.Naive.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//
//  Naive implementation of a functional pet runtime.

import Foundation
// import SwiftPriorityQueue

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

// MARK: for pet runtime
extension PetRuntime.Naive {
    static func observeRuntime(pet: PetIdentity, upTo date: Date = .now) -> RuntimeState {
        let stable = StableState(timestamp: pet.birthDate, state: .egg)
        return observeRuntime(commands: pet.userInputs!, starting: stable)
    }
    
    static func modify(pet: PetIdentity, action: Command.Action, at time: Date) {
        let command = Command(timestamp: time, action: action, pet: pet)
        modify(&pet.userInputs!, withNew: command)
    }
}

// MARK: implementation details
extension PetRuntime.Naive {
    struct TimeDependentVariable<T> {
        var calculateValueInFuture : (_: T, _ forward: TimeInterval) -> T
        var calculateTime : (_ initial: T, _ final: T) -> TimeInterval
    }
    
    static var fullnessVariable = TimeDependentVariable<Double>(
        calculateValueInFuture: {v, t in v - Double(t.minutes) / 600 },
        calculateTime: {i, f in TimeInterval((i - f) * 600 * 60 /* seconds */) })
    
    static func observeStable(
        commands: [Command],
        starting state: StableState,
        upTo date: Date = .now)
    -> StableState {
        var computedState = state
        for command in commands where command.timestamp <= date {
            let interval = command.timestamp.timeIntervalSince(computedState.timestamp)
            computedState = .init(timestamp: command.timestamp, state: transition(
                transition(
                    computedState.state,
                    forward: interval),
                with: command))
        }
        return computedState
    }
    
    static func observeRuntime(
        commands: [Command]?,
        starting state: StableState,
        upTo date: Date = .now)
    -> RuntimeState {
        let stable = commands != nil
        ? observeStable(commands: commands!, starting: state, upTo: date)
        : state
        let interval = date.timeIntervalSince(stable.timestamp)
        return transition(stable.state, forward: interval)
    }
    
    static func modify(_ commands: inout [Command], withNew command: Command) {
        // changes / add unaliveCommand to command list. This could also
        // handle adding additional future timed actions the pet takes.
        let maybeUnaliveIndex = commands
            .lastIndex(where: {cmd in cmd.action == .unalive })
        
        if let unaliveIndex = maybeUnaliveIndex {
            if command.timestamp <= commands[unaliveIndex].timestamp {
                commands.insert(command, at: unaliveIndex)
                commands[unaliveIndex].timestamp = deathstamp(fromComplete: commands)
            }
        } else if case .hatch = command.action {
            commands.append(command)
            commands.append(Command(
                timestamp: deathstamp(fromComplete: commands),
                action: .unalive,
                pet: command.pet!))
        }
        
        func deathstamp(fromComplete commands: [Command]) -> Date {
            let stableState = observeStable(
                commands: commands,
                starting: StableState(timestamp: command.pet!.birthDate, state: .egg),
                upTo: command.timestamp)
            return calculateDeathTimestamp(stable: stableState)
        }
    }
    
    static func calculateDeathTimestamp(stable state: StableState) -> Date {
        guard case .alive(let alive) = state.state else {
            fatalError() // trying calculating death timestamp when pet isn't alive
        }
        let interval = fullnessVariable.calculateTime(alive.fullness, 0)
        return state.timestamp + interval
    }
    
    static func transition(_ state: RuntimeState, with command: Command) -> RuntimeState {
        switch state {
        case .egg where command.action == .hatch:
                .alive(transition(alive: AliveState(), with: command))
        case .alive(_) where command.action == .unalive:
                .dead
        case .alive(let aliveState) where command.action != .hatch:
                .alive(transition(alive: aliveState, with: command))
        case .egg, .alive, .dead, .corrupted:
                .corrupted
        }
    }
    
    static func transition(_ state: RuntimeState, forward time: TimeInterval) -> RuntimeState {
        switch state {
        case .alive(let aliveState):
                .alive(transition(alive: aliveState, forward: time))
        case .egg, .dead, .corrupted:
            state
        }
    }
    
    private static func transition(alive: AliveState, with command: Command) -> AliveState {
        var state = alive
        switch command.action {
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
        state.fullness = fullnessVariable
            .calculateValueInFuture(state.fullness, time)
            .clamped(to: 0...1)
        state.happiness = (state.happiness - minutes / 1800).clamped(to: 0...1)
        return state
    }
}
