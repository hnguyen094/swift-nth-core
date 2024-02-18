//
//  SceneToggle.swift
//
//
//  Created by hung on 2/7/24.
//

import ComposableArchitecture
import SwiftUI

@MainActor
public struct SceneToggle: View {
    @Bindable var store: StoreOf<SceneLifecycle>

    @State private var disabled: Bool = false

    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    #endif
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var text: LocalizedStringKey
    var textOnFalse: LocalizedStringKey?
    var scene: SceneLifecycle.SceneType

    var binding: Binding<Bool> {
        .init(
            get: {
                switch scene {
                case .immersive(let id):
                    store.openedImmersiveSpace == id
                case .window(let openableWindow):
                    store.openedWindows.contains(openableWindow)
                }
            },
            set: { _ in
                guard !disabled else { return }
                switch scene {
                case .immersive(let id):
                    #if os(visionOS)
                    disabled = true
                    Task {
                        if store.openedImmersiveSpace == id {
                            await dismissImmersiveSpace()
                        } else {
                            await openImmersiveSpace(id: id)
                        }
                        disabled = false
                    }
                    #else
                    break
                    #endif
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
        )
    }
    
    public init(
        _ text: LocalizedStringKey,
        _ textOnFalse: LocalizedStringKey? = .none,
        toggling: SceneLifecycle.SceneType,
        using store: StoreOf<SceneLifecycle>
    ) {
        self.store = store
        self.text = text
        self.textOnFalse = textOnFalse
        self.scene = toggling
    }

    public var body: some View {
        let shownText = binding.wrappedValue ? text : (textOnFalse ?? text)
        Toggle(shownText, isOn: binding)
            .disabled(disabled)
    }
}
