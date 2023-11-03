//
//  VariableMicroSystem.swift
//  keepers
//
//  Created by Hung on 10/15/23.
//

import Foundation

protocol PetRuntimeVariableMicroSystem: VariableMicroSystem
where Value == UInt8, Action == Record.Action, State == PetRuntime.AliveState {
}

// describes a variable that could move forward in time, be predictable in time,
// transition forward with a command
protocol VariableMicroSystem<Value, Action, State> {
    associatedtype Value: Comparable
    associatedtype Action: Equatable
    associatedtype State: Equatable
    
    static func update(with action: Action, from state: State) -> Value
    /// The ``when(valueBecomes:from:)`` function but solving for final value.
    static func update(over time: TimeInterval, from state: State) -> Value
    /// The ``update(over:from:)`` function but solving for time.
    static func when(valueBecomes finalValue: Value, from state: State) -> TimeInterval
}
