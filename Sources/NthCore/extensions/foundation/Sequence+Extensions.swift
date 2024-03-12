//
//  Sequence+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import Foundation

public extension Sequence {
    func compact<T>() -> [T] where Element == Optional<T> {
        return compactMap { $0 }
    }
}
