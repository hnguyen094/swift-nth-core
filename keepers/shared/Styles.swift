//
//  Styles.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI

// https://medium.com/@_DandyLyons/7-ways-to-organize-swiftui-code-e786307d3916#9d0a
/// Example style for a red circle button.
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
