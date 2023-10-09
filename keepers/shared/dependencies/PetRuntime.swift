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

/// turns a `PetIdentity` into a deterministic runtime state for a given point in time.
struct PetRuntime {
    var observeRuntime: (_ pet: PetIdentity, _ date: Date) -> RuntimeState
    var modify: (_ pet: PetIdentity, _ action: Command.Action, _ date: Date) -> Void
  
    
    struct StableState {
        var timestamp: Date
        var state: RuntimeState
    }
    
    enum RuntimeState {
        case egg
        case alive(AliveState)
        case dead
        
        case corrupted
    }
    struct AliveState: Equatable {
        var fullness: Double = 0.5
        var happiness: Double = 0.5
        // TODO: add more computed variables as discussed
    }
}

extension PetRuntime: DependencyKey {
    static var liveValue: Self { naive }
}

extension PetRuntime {
    static var naive: Self {
        return .init(
            observeRuntime: Naive.observeRuntime(pet:upTo:),
            modify: Naive.modify(pet:action:at:)
        )
    }
    enum Naive {
        typealias StableState = PetRuntime.StableState
        typealias RuntimeState = PetRuntime.RuntimeState
        typealias AliveState = PetRuntime.AliveState
    }
}
