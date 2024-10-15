//
//  WeakBox.swift
//  keepers
//
//  Created by Hung on 10/12/23.
//

import Foundation

public final class WeakBox<A: AnyObject> {
    public weak var unbox: A?
    public init(_ value: A) {
        unbox = value
    }
}
