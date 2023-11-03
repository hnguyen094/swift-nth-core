//
//  Fullness.swift
//  keepers
//
//  Created by Hung on 10/17/23.
//

import Foundation

struct Fullness: PetRuntimeVariableMicroSystem {
    static func update(with action: Record.Action, from state: PetRuntime.AliveState) -> UInt8 {
        switch action {
        case .feed(let amount):
            return state.fullness + amount
        case .noop, .hatch, .play, .unalive:
            return state.fullness
        }
    }
    
    static func update(over time: TimeInterval, from state: PetRuntime.AliveState) -> UInt8 {
        return state.fullness - UInt8(time.seconds / 600)
    }
    
    static func when(valueBecomes finalValue: UInt8, from state: PetRuntime.AliveState) -> TimeInterval {
        return TimeInterval(600 * Int(state.fullness - finalValue))
    }
}
