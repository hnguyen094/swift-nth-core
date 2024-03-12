//
//  Color+Extensions.swift
//
//
//  Created by hung on 3/2/24.
//
// https://stackoverflow.com/a/75716714
// https://anoop4real.medium.com/swift-generate-color-hash-uicolor-from-string-names-e0aa129fec6a

import SwiftUI

public extension Color {
    var luminance: Float {
        let resolved = self.resolve(in: .init())
        return 0.2126 * resolved.red + 0.7152 * resolved.green + 0.0722 * resolved.blue
    }

    static func label(background: Self) -> Self {
        if background.luminance < 0.5 {
            return .white
        }
        return .black
    }

    static func generate(from source: String) -> Self {
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in source.unicodeScalars {
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);

        return .init(
            red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0,
            blue: CGFloat((finalHash & 0xFF)) / 255.0)
    }
}

