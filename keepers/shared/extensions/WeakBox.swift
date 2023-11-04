//
//  WeakBox.swift
//  keepers
//
//  Created by Hung on 10/12/23.
//

import Foundation

final class WeakBox<A: AnyObject> {
    weak var unbox: A?
    init(_ value: A) {
        unbox = value
    }
}
