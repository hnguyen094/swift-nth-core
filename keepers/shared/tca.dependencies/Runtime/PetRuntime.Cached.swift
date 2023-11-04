//
//  PetRuntime.Cached.swift
//  keepers
//
//  Created by Hung on 10/11/23.
//

/// We love naive implementations! We need to make it more performant though.
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
 
import Foundation

// TODO: in the case that we delete some actions, the cache will be wrong, and the only way to recover is to force a reobserve after hatch but before first action
extension PetRuntime.Cached {
    mutating func observeRuntime(pet: Creature, upTo time: Date = .now) -> RuntimeState {
        var stable = petCache[pet, default: Naive.generateStartingState(pet: pet)]
        if time < stable.timestamp { // our cache is "in the future"
            stable = Naive.generateStartingState(pet: pet)
        }
        let sortedCommands = pet.records!.sorted(by: <)
        guard let index = sortedCommands
            .firstIndex(where: { $0.timestamp > stable.timestamp }) else {
            return stable.runtime // no commands after stable timestamp, no action
        }
        let futureCommands = sortedCommands[index...]
        let (endStable, runtime) = observeRuntime(commands: futureCommands, starting: stable, upTo: time)
        petCache[pet] = endStable
        return runtime
    }
    
    func modify(pet: Creature, action: Record.Action, at time: Date) {
        let command = Record(timestamp: time, action: action, pet: pet)
        
        var stable = petCache[pet, default: Naive.generateStartingState(pet: pet)]
        if time < stable.timestamp { // our cache is "in the future"
            stable = Naive.generateStartingState(pet: pet)
        }
        let sortedCommands = pet.records!.sorted(by: <)
        guard let index = sortedCommands
            .firstIndex(where: { $0.timestamp > stable.timestamp }) else {
            // we're empty!
            fatalError() // there are no timestamps that we can run
        }
        let futureCommands = sortedCommands[index...]
        let newCommands = Naive.modify(nonpast: futureCommands, of: pet, withNew: command, from: stable)
        pet.records = sortedCommands + newCommands
    }

    func observeRuntime(
        commands: (any Sequence<Record>)?,
        starting state: StableState,
        upTo date: Date)
    -> (StableState, RuntimeState) {
        let stable = commands != nil
        ? Naive.observeStable(commands: commands!, starting: state, upTo: date)
        : state
        let interval = date.timeIntervalSince(stable.timestamp)
        return (stable, Naive.transition(stable.runtime, forward: interval))
    }
}

extension PetRuntime {
    struct Cached {
        typealias StableState = PetRuntime.StableState
        typealias RuntimeState = PetRuntime.RuntimeState
        typealias AliveState = PetRuntime.AliveState
        typealias Naive = PetRuntime.Naive
        
        var petCache = [Creature: StableState]()
    }
}
