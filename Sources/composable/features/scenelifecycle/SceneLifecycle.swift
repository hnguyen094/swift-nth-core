//
//  SceneLifecycle.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import ComposableArchitecture

@Reducer
public struct SceneLifecycle<ID>
where
    ID: RawRepresentable & Hashable & Sendable,
    ID.RawValue == String
{
    public enum Openable: Hashable, Sendable {
        case id(ID)
        case value(any (Codable & Hashable & Sendable))
        case both(id: ID, value: any (Codable & Hashable & Sendable))

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
        case immersive(Openable)
        case window(Openable)
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public var openedImmersiveSpace: Openable? = .none
        public var openedWindows: Set<Openable> = .init()
        public init() { }
    }

    public enum Action {
        case immersiveSpaceOpened(Openable)
        case immersiveSpaceClosed(Openable)
        case windowOpened(Openable)
        case windowClosed(Openable)
    }

    public init() { }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .immersiveSpaceOpened(let space):
                state.openedImmersiveSpace = space
                return .none
            case .immersiveSpaceClosed(let space):
                if state.openedImmersiveSpace == space {
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
