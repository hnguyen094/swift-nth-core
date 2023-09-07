//
//  Styles.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI

/// Example style for a red circle button.
///
/// This comes from [here](https://medium.com/@_DandyLyons/7-ways-to-organize-swiftui-code-e786307d3916#9d0a).
struct RedCircleButtonStyle: ButtonStyle {
    public func makeBody(configuration: RedCircleButtonStyle.Configuration) -> some View {
        RedCircleButton(configuration: configuration)
    }
    
    struct RedCircleButton: View {
        let configuration: RedCircleButtonStyle.Configuration

        var body: some View {
            configuration.label
                .foregroundColor(.red)
                .clipShape(Circle())
        }
    }
}

/// Sample ViewModifier used in the sample flashcards app.
///
/// This comes from [here](https://developer.apple.com/documentation/SwiftUI/Building-a-document-based-app-using-SwiftData).
struct HorizontalFlip: ViewModifier {
    var angle: Angle
    var visible: Bool
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(angle, axis: (x: 0.0, y: 1.0, z: 0.0))
            .opacity(visible ? 1.0 : 0.0)
    }
}

extension View {
    func horizontalFlip(_ angle: Angle, visible: Bool) -> some View {
        modifier(HorizontalFlip(angle: angle, visible: visible))
    }
}
