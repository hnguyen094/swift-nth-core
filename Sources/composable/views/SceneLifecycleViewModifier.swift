//
//  SceneLifecycleViewModifier.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import SwiftUI
import ComposableArchitecture

extension View {
    public func registerLifecycle<ID: RawRepresentable & Hashable>(
        _ store: StoreOf<SceneLifecycle<ID>>,
        as sceneType: SceneLifecycle<ID>.SceneType
    ) -> some View where ID.RawValue == String {
        self.modifier(Modifier<ID>(
            store: store,
            sceneType: sceneType))
    }
}

private struct Modifier<ID: RawRepresentable & Hashable>: ViewModifier where ID.RawValue == String {
    @Bindable var store: StoreOf<SceneLifecycle<ID>>
    var sceneType: SceneLifecycle<ID>.SceneType

    func body(content: Content) -> some View {
        content
            .onAppear {
                switch sceneType {
                case .immersive(let id):
                    store.send(.immersiveSpaceOpened(id: id))
                case .window(let openableWindow):
                    store.send(.windowOpened(openableWindow))
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
