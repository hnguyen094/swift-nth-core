//
//  SceneToggle.swift
//
//
//  Created by hung on 2/7/24.
//

import ComposableArchitecture
import SwiftUI

public struct SceneToggle: View {
    @Bindable var store: StoreOf<SceneLifecycle>

    @State var toggleRequest: Bool = false
    @State private var disabled: Bool = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var text: LocalizedStringKey
    var scene: SceneLifecycle.SceneType

    public init(
        _ text: LocalizedStringKey,
        scene: SceneLifecycle.SceneType,
        using store: StoreOf<SceneLifecycle>
    ) {
        self.store = store
        self.text = text
        self.scene = scene
    }

    public var body: some View {
        Toggle(text, isOn: $toggleRequest)
            .disabled(disabled)
            .onChange(of: toggleRequest) {
                guard !disabled else { return }
                switch scene {
                case .immersive(let id):
                    disabled = true
                    Task {
                        if store.openedImmersiveSpace == id {
                            await dismissImmersiveSpace()
                            toggleRequest = false
                        } else {
                            let result = await openImmersiveSpace(id: id)
                            toggleRequest = switch result {
                            case .opened: true
                            default: false
                            }
                        }
                        disabled = false
                    }
                case .window(let openableWindow):
                    let opened = store.openedWindows.contains(openableWindow)
                    switch openableWindow {
                    case .id(let id):
                        opened
                        ? dismissWindow(id: id)
                        : openWindow(id: id)
                    case .value(let value):
                        opened
                        ? dismissWindow(value: value)
                        : openWindow(value: value)
                    case .both(id: let id, value: let value):
                        opened
                        ? dismissWindow(id: id, value: value)
                        : openWindow(id: id, value: value)
                    }
                }
            }
    }
}
