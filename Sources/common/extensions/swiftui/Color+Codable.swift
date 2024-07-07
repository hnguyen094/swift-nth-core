//
//  Color+Codable.swift
//  
//
//  Created by hung on 7/8/24.
//

import SwiftUI

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let resolved = self.resolve(in: .init())
        try container.encode(resolved.red, forKey: .red)
        try container.encode(resolved.green, forKey: .green)
        try container.encode(resolved.blue, forKey: .blue)
        try container.encode(resolved.opacity, forKey: .alpha)
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let red = Double(try values.decode(Float.self, forKey: .red))
        let green = Double(try values.decode(Float.self, forKey: .green))
        let blue = Double(try values.decode(Float.self, forKey: .blue))
        let alpha = Double(try values.decode(Float.self, forKey: .alpha))
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
