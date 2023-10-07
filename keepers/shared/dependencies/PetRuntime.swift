//
//  PetRuntime.swift
//  keepers
//
//  Created by Hung on 10/2/23.
//
//  Pet runtime system.

import Foundation
import Dependencies
import SwiftPriorityQueue

extension DependencyValues {
    var petRuntime: PetRuntime {
        get { self[PetRuntime.self] }
        set { self[PetRuntime.self] = newValue }
    }
}

/// turns a `PetIdentity` into a deterministic runtime state for a given point in time.
struct PetRuntime {
    var observe: (_ pet: PetIdentity, _ date: Date) -> State
    var submit: (_ pet: PetIdentity, _ action: Command.Action, _ date: Date) -> Void
    
    enum State {
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
            observe: Naive.observe(pet:upTo:),
            submit: Naive.submit(pet:action:at:)
        )
    }
}
