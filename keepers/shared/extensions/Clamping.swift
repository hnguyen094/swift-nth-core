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
struct Clamping<Value: Comparable>: Equatable {
    var value: Value
    
    let lower: Value?
    let upper: Value?
    
    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.lower = range.lowerBound
        self.upper = range.upperBound
    }
    init(wrappedValue value: Value, _ range: PartialRangeFrom<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.lower = range.lowerBound
        self.upper = nil
    }
    init(wrappedValue value: Value, _ range: PartialRangeThrough<Value>) {
        precondition(range.contains(value))
        self.value = value
        self.lower = nil
        self.upper = range.upperBound
    }
    
    var wrappedValue: Value {
        get { value }
        set {
            value = (lower != nil) ? max(lower!, newValue) : newValue
            value = (upper != nil) ? min(value, upper!) : value
        }
    }
}
