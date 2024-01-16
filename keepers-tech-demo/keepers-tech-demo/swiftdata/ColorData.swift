//
//  ColorData.swift
//  keepers-tech-demo
//
//  Created by hung on 1/16/24.
//

import SwiftUI
import RealityKit

struct ColorData: Codable {
    let red: Float
    let green: Float
    let blue: Float
}

extension ColorData {
    func toColor() -> Creature.Backing.Color {
        .init(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension Creature.Backing.Color {
    func toColorData() -> ColorData {
        let resolved = self.resolve(in: .init())
        return .init(red: resolved.red, green: resolved.green, blue: resolved.blue)
    }
}
