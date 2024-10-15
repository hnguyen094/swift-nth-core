//
//  ButtonNavigationLink.swift
//  flaky-mvp
//
//  Created by Hung Nguyen on 9/26/24.
//
//  A button disguising as a navigation link.

import SwiftUI

// Note that it is likely better to not use this if it doesn't work for the use case.
// For example, this should just be reimplemented when an icon label style is required.
public struct ButtonNavigationLink: View {
    public var titleKey: LocalizedStringKey
    public var action: () -> Void

    public init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
        self.titleKey = titleKey
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            NavigationLink(titleKey, destination: EmptyView())
        }
        .foregroundStyle(.primary)
    }
}
