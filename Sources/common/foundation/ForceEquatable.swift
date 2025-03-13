//
//  ForceEquatable.swift
//  worlds
//
//  Created by Hung Nguyen on 3/12/25.
//

@propertyWrapper
public struct ForceEquatable<Value>: Equatable {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public static func == (lhs: Self, rhs: Self) -> Bool { true }
}
