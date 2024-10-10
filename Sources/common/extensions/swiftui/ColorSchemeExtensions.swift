//
//  ColorSchemeExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 9/16/24.
//

import SwiftUI

public extension ColorScheme {
    #if os(iOS)
    @MainActor
    static var system: Optional<Self> {
        guard let style = UIScreen.current?.traitCollection.userInterfaceStyle
        else { return .none }
        return .init(style)
    }
    #endif

    func preferring(_ preferred: ColorScheme?) -> Self {
        switch preferred {
        case let .some(value): value
        case .none: self
        }
    }
}

extension ColorScheme: @retroactive RawRepresentable {
    public init?(rawValue: Int) {
        guard let style = UIUserInterfaceStyle(rawValue: rawValue),
              let validColorScheme = Self.init(style)
        else { return nil }
        self = validColorScheme
    }

    public var rawValue: Int {
        let style = UIUserInterfaceStyle(self)
        return style.rawValue
    }
}
