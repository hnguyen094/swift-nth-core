//
//  SceneLifecycleViewModifier.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import SwiftUI
import ComposableArchitecture

extension View {
    public func registerLifecycle(
        _ store: StoreOf<SceneLifecycle>,
        as sceneType: SceneLifecycle.SceneType
    ) -> some View {
        self.modifier(Modifier(
            store: store,
            sceneType: sceneType))
    }
}

private struct Modifier: ViewModifier {
    @Bindable var store: StoreOf<SceneLifecycle>
    var sceneType: SceneLifecycle.SceneType

    func body(content: Content) -> some View {
        content
            .onAppear {
                let action: SceneLifecycle.Action = switch sceneType {
                case .immersive(let id):
                    .immersiveSpaceOpened(id: id)
                case .window(let openableWindow):
                    .windowOpened(openableWindow)
                }
                store.send(action)
            }
            .onDisappear {
                let action: SceneLifecycle.Action = switch sceneType {
                case .immersive(let id):
                    .immersiveSpaceClosed(id: id)
                case .window(let openableWindow):
                    .windowClosed(openableWindow)
                }
                store.send(action)
            }
    }
}
