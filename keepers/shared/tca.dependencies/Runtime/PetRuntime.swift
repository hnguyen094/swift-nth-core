//
//  PetRuntime.swift
//  keepers
//
//  Created by Hung on 10/2/23.
//
//  Pet runtime system.

import Foundation
import Dependencies
import NthCore

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
        // these are the bars
        var fullness: UInt8 = 50
        var liquidFullness: UInt8 = 0
        var cleanliness: UInt8 = 0
        var energy: UInt8 = 0
        var happiness: UInt8 = 0
        
        var changingNeeds = Needs()
    }
    
    struct Needs: Equatable {
        // food
        var hungerRate: UInt8 = 0 // some units of food per time
        var foodBias: UInt8 = 0
        var fullnessCapacity: UInt8 = 0
        
        // hydration
        var thirstRate: UInt8 = 0
        var liquidBias: UInt8 = 0
        var liquidCapacity: UInt8 = 0
        
        // cleanliness
        var dirtyRate: UInt8 = 0
        var selfCleanCapability: UInt8 = 0
        var cleanlinessBias: UInt8 = 0
        
        // energy + activeness
        var energyConsumptionRate: UInt8 = 0
        var energyCapacity: UInt8 = 0
        var activenessBias: UInt8 = 0
        
        // temperature
        var minimumTemperature: UInt8 = 0
        var maximumTemperature: UInt8 = 0
        var preferredTemperature: UInt8 = 0
        
        // curiosity, attention
        var curiosityBias: UInt8 = 0
        var attentionBias: UInt8 = 0
        
        // happiness
        var happinessSensitivity: UInt8 = 0
        
        // social/confidence
        var socialBias: UInt8 = 0
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
