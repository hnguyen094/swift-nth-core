//
//  TimeDependent.swift
//  keepers
//
//  Created by Hung on 10/13/23.
//

import Foundation

@propertyWrapper
struct TimeDependent<T: Equatable>: Equatable {
    static func == (lhs: TimeDependent<T>, rhs: TimeDependent<T>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    var wrappedValue: T
    private var forwardImpl : (_: T, _ forward: TimeInterval) -> T
    private var timeUntilImpl : (_ initial: T, _ final: T) -> TimeInterval
    
    init(
        wrappedValue: T,
        valueForward forwardImpl: @escaping (_: T, _: TimeInterval) -> T,
        timeBetween timeUntilImpl: @escaping (_: T, _: T) -> TimeInterval) {
            self.wrappedValue = wrappedValue
            self.forwardImpl = forwardImpl
            self.timeUntilImpl = timeUntilImpl
        }
    
    func forward(_ forward: TimeInterval) -> T {
        forwardImpl(self.wrappedValue, forward)
    }
    
    func timeUntil(_ final: T) -> TimeInterval {
        timeUntilImpl(self.wrappedValue, final)
    }
}
