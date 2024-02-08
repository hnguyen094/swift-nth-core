//
//  SceneLifecycle.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import ComposableArchitecture

@Reducer
public struct SceneLifecycle {
    public enum OpenableWindow: Hashable {
        case id(String)
        case value(any (Codable & Hashable))
        case both(id: String, value: any(Codable & Hashable))

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .id(let id):
                hasher.combine(id)
            case .value(let value):
                hasher.combine(value)
            case .both(id: let id, value: let value):
                hasher.combine(id)
                hasher.combine(value)
            }
        }
    }

    public enum SceneType {
        case immersive(String)
        case window(OpenableWindow)
    }

    @ObservableState
    public struct State {
        public var openedImmersiveSpace: String? = .none
        public var openedWindows: Set<OpenableWindow> = .init()
        public init() { }
    }

    public enum Action {
        case immersiveSpaceOpened(id: String)
        case immersiveSpaceClosed(id: String)
        case windowOpened(OpenableWindow)
        case windowClosed(OpenableWindow)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .immersiveSpaceOpened(id: let id):
                state.openedImmersiveSpace = id
                return .none
            case .immersiveSpaceClosed(id: let id):
                if state.openedImmersiveSpace == id {
                    state.openedImmersiveSpace = .none
                }
                return .none
            case .windowOpened(let window):
                state.openedWindows.insert(window)
                return .none
            case .windowClosed(let window):
                state.openedWindows.remove(window)
                return .none
            }
        }
    }
}
