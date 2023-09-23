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
