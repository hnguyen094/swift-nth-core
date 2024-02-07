//
//  PetRuntime.Naive.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//
//  Naive implementation of a functional pet runtime.

import Foundation
import NthCore

// MARK: for pet runtime
extension PetRuntime.Naive {
    static func observeRuntime(pet: Creature, upTo date: Date = .now) -> RuntimeState {
        let stable = generateStartingState(pet: pet)
        let sortedCommands = pet.records!.sorted(by: <)
        return observeRuntime(commands: sortedCommands, starting: stable, upTo: date)
    }
    
    static func modify(pet: Creature, action: Record.Action, at time: Date) {
        let command = Record(timestamp: time, action: action, pet: pet)
        let sortedCommands = pet.records!.sorted(by: <)
        let newCommands = modify(nonpast: sortedCommands, of: pet, withNew: command)
        pet.records = sortedCommands + newCommands
    }
}

// MARK: implementation details
extension PetRuntime.Naive {
    static func observeStable(
        commands: any Sequence<Record>,
        starting: StableState,
        upTo date: Date = .now)
    -> StableState {
        var stable = starting
        for command in commands where command.timestamp <= date {
            let interval = command.timestamp.timeIntervalSince(stable.timestamp)
            stable = .init(
                timestamp: command.timestamp,
                rng: stable.rng,
                innate: stable.innate,
                runtime: transition(
                transition(
                    stable.runtime,
                    forward: interval),
                with: command))
        }
        return stable
    }
    
    static func observeRuntime(
        commands: (any Sequence<Record>)?,
        starting state: StableState,
        upTo date: Date)
    -> RuntimeState {
        let stable = commands != nil
        ? observeStable(commands: commands!, starting: state, upTo: date)
        : state
        let interval = date.timeIntervalSince(stable.timestamp)
        return transition(stable.runtime, forward: interval)
    }
    
    static func modify(
        nonpast commands: any BidirectionalCollection<Record>,
        of pet: Creature,
        withNew command: Record,
        from maybeStable: StableState? = nil) -> [Record]
    {
        let stable = maybeStable ?? generateStartingState(pet: pet)
        var outRecords = [Record]()
        
        // changes / add unaliveCommand to command list. This could also
        // handle adding additional future timed actions the pet takes.
        let maybeUnalive = commands
            .last(where: {cmd in cmd.action == .unalive })
        if let unalive = maybeUnalive {
            unalive.timestamp = deathstamp()
        } else if case .hatch = command.action {
            outRecords.append(Record(
                timestamp: deathstamp(),
                action: .unalive,
                pet: pet))
        }
        return outRecords
        func deathstamp() -> Date {
            let stableState = observeStable(
                commands: commands,
                starting: stable,
                upTo: command.timestamp)
            return calculateDeathTimestamp(stable: stableState)
        }
    }
    
    static func generateStartingState(pet: Creature) -> StableState {
        var stable = StableState(
            timestamp: pet.birthDate,
            rng: .init(
                seed: pet.seed,
                with: .LinearCongruential),
            innate: .init(),
            runtime: .egg)
        
        // random number from uniform output
        // this is between 0<= and <upperBound
        stable.innate.activenessBias = UInt8(stable.rng.nextInt(upperBound: Int(UInt8.max)))
        
        // sample number from norm distribution
        // has guarantees of 100% INSIDE +-3 std so in this case will never go above 130
        let norm = GaussianDistribution(
            randomSource: stable.rng,
            mean: 100,
            deviation: 10)
        stable.innate.curiosityBias = UInt8(norm.nextInt())
        stable.innate.socialBias = UInt8(norm.nextInt())
        
        return stable
    }
    
    static func calculateDeathTimestamp(stable state: StableState) -> Date {
        let maybeAlive: Optional<AliveState> = switch state.runtime {
        case .alive(let alive):
            alive
        case .egg:
            AliveState()
        case .corrupted, .dead:
            nil
        }
        guard let alive = maybeAlive else {
            return state.timestamp
        }
        return state.timestamp + Fullness.when(valueBecomes: 0, from: alive)
    }
    
    static func transition(_ state: RuntimeState, with command: Record) -> RuntimeState {
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
    
    private static func transition(alive: AliveState, with command: Record) -> AliveState {
        var state = alive
        state.fullness = Fullness.update(with: command.action, from: alive)
        // TODO: add other variables that change
        return state
    }
    
    private static func transition(alive: AliveState, forward time: TimeInterval) -> AliveState {
        var state = alive
        state.fullness = Fullness.update(over: time, from: alive)
        // TODO: add other variables that change
        return state
    }
}

extension PetRuntime {
    enum Naive {
        typealias StableState = PetRuntime.StableState
        typealias RuntimeState = PetRuntime.RuntimeState
        typealias AliveState = PetRuntime.AliveState
    }
}
