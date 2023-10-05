//
//  ComparableExtensions.swift
//  keepers
//
//  Created by Hung on 10/4/23.
//

import Foundation

extension Comparable {
    /// Clamps a comparable value to the given Range.
    /// - Author: [Ondrej Stocek](https://stackoverflow.com/a/40868784 ).
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
