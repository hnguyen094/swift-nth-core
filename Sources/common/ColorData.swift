//
//  ColorData.swift
//  keepers-tech-demo
//
//  Created by hung on 1/16/24.
//

import SwiftUI

public struct ColorData: Codable, Equatable {
    public let red: Float
    public let green: Float
    public let blue: Float
    
    public init(red: Float, green: Float, blue: Float) {
        self.red = red
        self.green = green
        self.blue = blue
    }
}

extension ColorData {
    public func toColor() -> SwiftUI.Color {
        .init(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension SwiftUI.Color {
    public func toColorData() -> ColorData {
        let resolved = self.resolve(in: .init())
        return .init(red: resolved.red, green: resolved.green, blue: resolved.blue)
    }
}
