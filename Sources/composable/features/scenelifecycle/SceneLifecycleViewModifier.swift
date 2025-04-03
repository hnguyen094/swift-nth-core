//
//  SceneLifecycleViewModifier.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import SwiftUI
import ComposableArchitecture

public extension View {
    #if os(visionOS)
    static var backgroundShouldDismiss: Bool { true }
    #else
    static var backgroundShouldDismiss: Bool { false }
    #endif
    /// Note: `backgroundingDismisses` only affects windows.

    @ViewBuilder
    func registerLifecycle<ID: RawRepresentable & Hashable & Sendable>(
        _ store: StoreOf<SceneLifecycle<ID>>,
        as sceneType: SceneLifecycle<ID>.SceneType,
        backgroundDismisses: Bool = backgroundShouldDismiss
    ) -> some View where ID.RawValue == String {
        let modified = self.modifier(Modifier<ID>(
            store: store,
            sceneType: sceneType
        ))
        switch backgroundDismisses {
        case true: modified.modifier(BackgroundDismissesModifier(sceneType: sceneType))
        case false: modified
        }
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
                case .immersive(let openableSpace):
                    await store.send(.immersiveSpaceOpened(openableSpace)).finish()
                case .window(let openableWindow):
                    await store.send(.windowOpened(openableWindow)).finish()
                }
            }
            .onDisappear {
                switch sceneType {
                case .immersive(let openableSpace):
                    store.send(.immersiveSpaceClosed(openableSpace))
                case .window(let openableWindow):
                    store.send(.windowClosed(openableWindow))
                }
            }
    }
}

private struct BackgroundDismissesModifier<ID>: ViewModifier
where
    ID: RawRepresentable & Hashable & Sendable,
    ID.RawValue == String
{
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismissWindow) var dismissWindow

    var sceneType: SceneLifecycle<ID>.SceneType

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) {
                guard case .background = scenePhase, case .window(let window) = sceneType
                else { return }
                switch window {
                case let .both(id, value): dismissWindow(id: id.rawValue, value: value)
                case let .id(id): dismissWindow(id: id.rawValue)
                case let .value(value): dismissWindow(value: value)
                }
            }
    }
}
