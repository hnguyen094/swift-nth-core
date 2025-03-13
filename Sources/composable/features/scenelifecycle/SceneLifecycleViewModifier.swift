//
//  SceneLifecycleViewModifier.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import SwiftUI
import ComposableArchitecture

extension View {
    public func registerLifecycle<ID: RawRepresentable & Hashable & Sendable>(
        _ store: StoreOf<SceneLifecycle<ID>>,
        as sceneType: SceneLifecycle<ID>.SceneType
    ) -> some View where ID.RawValue == String {
        self.modifier(Modifier<ID>(
            store: store,
            sceneType: sceneType))
    }
}

private struct Modifier<ID>: ViewModifier
where
    ID: RawRepresentable & Hashable & Sendable,
    ID.RawValue == String
{
    @Bindable var store: StoreOf<SceneLifecycle<ID>>
    var sceneType: SceneLifecycle<ID>.SceneType

    func body(content: Content) -> some View {
        content
            .task {
                switch sceneType {
                case .immersive(let id):
                    await store.send(.immersiveSpaceOpened(id: id)).finish()
                case .window(let openableWindow):
                    await store.send(.windowOpened(openableWindow)).finish()
                }
            }
            .onDisappear {
                switch sceneType {
                case .immersive(let id):
                    store.send(.immersiveSpaceClosed(id: id))
                case .window(let openableWindow):
                    store.send(.windowClosed(openableWindow))
                }
            }
    }
}
