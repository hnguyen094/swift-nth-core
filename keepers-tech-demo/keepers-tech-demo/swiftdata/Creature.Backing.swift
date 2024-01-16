//
//  Creature.Backing.swift
//  keepers-tech-demo
//
//  Created by hung on 1/15/24.
//

import Foundation
import SwiftUI
import SwiftData

extension Creature {
    typealias Backing = AppSchema.V1.CreatureBacking
}

extension AppSchema.V1 {
    @Model
    final class CreatureBacking: Hashable {
        var birthDate: Date = Date.now
        init() {}
    }
}
