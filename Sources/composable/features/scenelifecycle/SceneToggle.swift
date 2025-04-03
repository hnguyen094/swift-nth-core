//
//  SceneToggle.swift
//
//
//  Created by hung on 2/7/24.
//

import ComposableArchitecture
import SwiftUI

@MainActor
public struct SceneToggle<ID, ContentLabel>: View
where
    ID: RawRepresentable & Hashable & Sendable,
    ID.RawValue == String,
    ContentLabel: View
{
    @Bindable var store: StoreOf<SceneLifecycle<ID>>

    @State private var disabled: Bool = false

    #if os(visionOS)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    #endif
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var contentLabel: (_ opened: Bool) -> ContentLabel

    var scene: SceneLifecycle<ID>.SceneType

    var binding: Binding<Bool> {
        .init(
            get: {
                switch scene {
                case .immersive(let space):
                    store.openedImmersiveSpace == space
                case .window(let openableWindow):
                    store.openedWindows.contains(openableWindow)
                }
            },
            set: { _ in
                guard !disabled else { return }
                switch scene {
                case .immersive(let openableSpace):
                    #if os(visionOS)
                    disabled = true
                    Task {
                        if store.openedImmersiveSpace == openableSpace {
                            await dismissImmersiveSpace()
                        } else {
                            switch openableSpace {
                            case .id(let id):
                                await openImmersiveSpace(id: id.rawValue)
                            case .value(let value):
                                await openImmersiveSpace(value: value)
                            case let .both(id: id, value: value):
                                await openImmersiveSpace(id: id.rawValue, value: value)
                            }
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
                        ? dismissWindow(id: id.rawValue)
                        : openWindow(id: id.rawValue)
                    case .value(let value):
                        opened
                        ? dismissWindow(value: value)
                        : openWindow(value: value)
                    case .both(id: let id, value: let value):
                        opened
                        ? dismissWindow(id: id.rawValue, value: value)
                        : openWindow(id: id.rawValue, value: value)
                    }
                }
            }
        )
    }
    
    public init(
        toggling: SceneLifecycle<ID>.SceneType,
        using store: StoreOf<SceneLifecycle<ID>>,
        @ViewBuilder label: @escaping (Bool) -> ContentLabel
    ) {
        self.store = store
        self.contentLabel = label
        self.scene = toggling
    }

    public var body: some View {
        Toggle(isOn: binding, label: { contentLabel(binding.wrappedValue) })
            .disabled(disabled)
    }

}

public extension SceneToggle where ContentLabel == Text {
    init(
        _ text: LocalizedStringKey,
        _ textOnFalse: LocalizedStringKey? = .none,
        toggling: SceneLifecycle<ID>.SceneType,
        using store: StoreOf<SceneLifecycle<ID>>
    ) {
        self.store = store
        self.contentLabel = { Self.textToView(text: text, textOnFalse: textOnFalse, opened: $0) }
        self.scene = toggling
    }

    private static func textToView(
        text: LocalizedStringKey,
        textOnFalse: LocalizedStringKey?,
        opened: Bool
    ) -> Text {
        guard let falseText = textOnFalse else {
            return Text(text)
        }
        return Text(opened ? text : falseText)
    }
}
