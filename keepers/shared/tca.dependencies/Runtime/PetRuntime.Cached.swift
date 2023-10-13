//
//  PetRuntime.Cached.swift
//  keepers
//
//  Created by Hung on 10/11/23.
//

import Foundation
extension PetRuntime {
    struct Cached {
        typealias StableState = PetRuntime.StableState
        typealias RuntimeState = PetRuntime.RuntimeState
        typealias AliveState = PetRuntime.AliveState
        typealias Naive = PetRuntime.Naive
        
        var petCache = [Creature: StableState]()
    }
}


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
