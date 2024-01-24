//
//  Creature.Backing.swift
//  keepers-tech-demo
//
//  Created by hung on 1/15/24.
//

import SwiftData

import Foundation
import SwiftUI

extension Creature {
    typealias Backing = AppSchema.V1.CreatureBacking
}

extension AppSchema.V1 {
    @Model
    final class CreatureBacking: Hashable {
        typealias Color = SwiftUI.Color
                
        var birthDate: Date = Date.now
        var name: String = "Ami"
        var color: ColorData = ColorData(red: 0.5, green: 0.5, blue: 0.5)
        
        init() {}
    }
}
