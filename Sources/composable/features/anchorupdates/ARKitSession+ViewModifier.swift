//
//  ARKitSession.FeatureViewModifier.swift
//  worlds
//
//  Created by Hung Nguyen on 3/12/25.
//

import SwiftUI
import ComposableArchitecture
import ARKit

#if os(visionOS)
extension View {
    public func arkitsession<State, Action>(
        _ store: Store<State, Action>
    ) -> some View where Action: ARKitSession.Action {
        self.modifier(Modifier<State, Action>(store: store))
    }
}

private struct Modifier<State, Action>: ViewModifier where Action: ARKitSession.Action {
    @SwiftUI.State var session: ARKitSession = .init()
    @Bindable var store: Store<State, Action>

    func body(content: Content) -> some View {
        content
            .task {
                await store.send(.task(session)).finish()
            }
    }
}
#endif
