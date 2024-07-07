//
//  ColorData.swift
//  keepers-tech-demo
//
//  Created by hung on 1/16/24.
//

import SwiftUI

@available(*, deprecated, message: "Conforming Color to Codable means this is no longer required.")
public struct ColorData: Codable, Equatable {
    public let red: Float
    public let green: Float
    public let blue: Float
    public let alpha: Float

    public init(red: Float, green: Float, blue: Float, alpha: Float = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension ColorData {
    public func toColor() -> SwiftUI.Color {
        .init(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }

    public static func from(_ color: SwiftUI.Color) -> Self {
        color.toColorData()
    }
}

extension SwiftUI.Color {
    public func toColorData() -> ColorData {
        let resolved = self.resolve(in: .init())
        return .init(red: resolved.red, 
                     green: resolved.green,
                     blue: resolved.blue,
                     alpha: resolved.opacity)
    }
}
