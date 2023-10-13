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
    var observeRuntime: (_ pet: Creature, _ date: Date) -> RuntimeState
    var modify: (_ pet: Creature, _ action: Record.Action, _ date: Date) -> Void
  
    
    struct StableState {
        var timestamp: Date
        var rng: ReproducibleRandomSource
        var innate: Needs
        var runtime: RuntimeState
    }
    
    enum RuntimeState: Equatable {
        case egg
        case alive(AliveState)
        case dead
        
        case corrupted
    }
    struct AliveState: Equatable {
        var fullness: UInt8 = 50
        var hydration: UInt8 = 0
        var cleanliness: UInt8 = 0
        var energy: UInt8 = 0
        var happiness: UInt8 = 0
        
        var changingNeeds = Needs()

        // TODO: another way to define the time. Ignore for now.
        @TimeDependent(
            valueForward: {value, time in UInt8(Int(value) - time.minutes) },
            timeBetween: {initial, final in TimeInterval(Int(initial - final) * 60 /* seconds */) })
        var full: UInt8 = 0
    }
    
    struct Needs: Equatable {
        var fullness: UInt8 = 0
        var hydration: UInt8 = 0
        var cleanliness: UInt8 = 0
        var energy: UInt8 = 0
        var activeness: UInt8 = 0
        var temperature: UInt8 = 0
        var curiosity: UInt8 = 0
        var entertainment: UInt8 = 0
        var sensitivity: UInt8 = 0
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
    
    static var cached: Self {
        var cachedRuntime = Cached()
        return .init(
            observeRuntime: { p, t in cachedRuntime.observeRuntime(pet:p, upTo: t) },
            modify: cachedRuntime.modify(pet:action:at:))
    }
}
