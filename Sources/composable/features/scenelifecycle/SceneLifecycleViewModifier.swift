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
        case true: modified.modifier(BackgroundDismisses(store: store, sceneType: sceneType))
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

private struct BackgroundDismisses<ID>: ViewModifier
where
    ID: RawRepresentable & Hashable & Sendable,
    ID.RawValue == String
{
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismissWindow) var dismissWindow
    #if os(visionOS)
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    #endif

    @Bindable var store: StoreOf<SceneLifecycle<ID>>
    var sceneType: SceneLifecycle<ID>.SceneType

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase, initial: true) {
                guard case .background = scenePhase else { return }

                switch sceneType {
                case .window(let window):
                    switch window {
                    case let .both(id, value): dismissWindow(id: id.rawValue, value: value)
                    case let .id(id): dismissWindow(id: id.rawValue)
                    case let .value(value): dismissWindow(value: value)
                    }
                // workaround for AppIntents starts (xros 2.5)
                case .immersive(let immersive):
                    #if os(visionOS)
                    guard store.openedImmersiveSpace != immersive else { break }
                    Task { await dismissImmersiveSpace() }
                    #else
                    break
                    #endif
                }
            }
    }
}
