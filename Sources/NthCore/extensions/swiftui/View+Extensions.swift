//
//  View+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI

public extension View {
    static var ID: String { .init(describing: Body.self) }

    /// Combines `clipShape` and `overlay` with `strokeBorder`.
    @ViewBuilder
    func clipShapeWithStrokeBorder<I, S>(
        _ shape: I,
        _ content: S = .foreground,
        style: StrokeStyle
    ) -> some View where I : InsettableShape, S : ShapeStyle {
        self
            .clipShape(shape)
            .overlay { shape.strokeBorder(content, style: style) }
    }
}
