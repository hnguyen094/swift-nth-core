//
//  Binding+Extensions.swift
//  keepers
//
//  Created by Hung on 9/10/23.
//

import SwiftUI

public extension Binding {
    /// Allows converting Int bindings to become `Float`. Useful for Sliders.
    /// - Author: [Mark A. Donohoe](https://stackoverflow.com/a/74356845 ).
    static func convert<TInt, TFloat>(from intBinding: Binding<TInt>) -> Binding<TFloat>
    where TInt:   BinaryInteger,
          TFloat: BinaryFloatingPoint{
        Binding<TFloat> (
            get: { TFloat(intBinding.wrappedValue) },
            set: { intBinding.wrappedValue = TInt($0) }
        )
    }

    /// Allows converting Int bindings to become `Float`. Useful for Sliders.
    /// - Author: [Mark A. Donohoe](https://stackoverflow.com/a/74356845 ).
    static func convert<TFloat, TInt>(from floatBinding: Binding<TFloat>) -> Binding<TInt>
    where TFloat: BinaryFloatingPoint,
          TInt:   BinaryInteger {
        Binding<TInt> (
            get: { TInt(floatBinding.wrappedValue) },
            set: { floatBinding.wrappedValue = TFloat($0) }
        )
    }
    
    static func convert<TInt>(from intBinding: Binding<TInt>) -> Binding<String>
    where TInt: BinaryInteger {
        Binding<String> (
            get: { String(intBinding.wrappedValue) },
            set: {v in
                do {
                    intBinding.wrappedValue = try TInt.init(v, format: IntegerFormatStyle.init(), lenient: true)
                } catch {
                    intBinding.wrappedValue = 0
                }
            }
        )
    }
}
