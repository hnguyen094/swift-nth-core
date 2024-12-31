//
//  ExpandedDisclosureGroupStyle.swift
//  touch-type
//
//  Created by Hung Nguyen on 12/31/24.
//

import SwiftUI

public extension DisclosureGroupStyle where Self == ExpandedDisclosureGroupStyle {
    /// Same as automatic disclosure group style, but expanded by default.
    static var expanded: Self {
        ExpandedDisclosureGroupStyle()
    }
}

public struct ExpandedDisclosureGroupStyle: DisclosureGroupStyle {
    public func makeBody(configuration: Configuration) -> some View {
        DisclosureGroup(isExpanded: configuration.$isExpanded) {
            configuration.content
        } label: {
            configuration.label
        }
        .onAppear { configuration.isExpanded = true }
    }
}
