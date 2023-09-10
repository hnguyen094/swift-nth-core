//
//  ViewExtensions.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI

extension View {
    /// Returns itself. Replaces `{ $0 }`.
    public func identity<A>(id: A) -> A {
        return id
    }
}
