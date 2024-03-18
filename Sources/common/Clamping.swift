//
//  Clamping.swift
//  keepers
//
//  Created by Hung on 10/12/23.
//

import Foundation


/// Clamps value in range. Requires initial value.
///
/// - Author: [Mattt](https://nshipster.com/propertywrapper/) with modifications for other ranges.
@propertyWrapper
public struct Clamping<Value: Comparable>: Equatable {
    public var value: Value
    
    public let lower: Value?
    public let upper: Value?
    
    public init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.lower = range.lowerBound
        self.upper = range.upperBound
    }
    public init(wrappedValue value: Value, _ range: PartialRangeFrom<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.lower = range.lowerBound
        self.upper = nil
    }
    public init(wrappedValue value: Value, _ range: PartialRangeThrough<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.lower = nil
        self.upper = range.upperBound
    }
    
    public var wrappedValue: Value {
        get { value }
        set {
            value = (lower != nil) ? max(lower!, newValue) : newValue
            value = (upper != nil) ? min(value, upper!) : value
        }
    }
}
