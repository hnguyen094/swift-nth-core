//
//  ARKitSession+Reducer.swift
//  worlds
//
//  Created by Hung Nguyen on 3/13/25.
//

#if os(visionOS)
import ARKit
import ComposableArchitecture

public extension ARKitSession {
    protocol State {
        var session: ARKitSession { get }
        var updates: [any AnchorUpdatesState] { get }
    }

    protocol Action: Sendable {
        static var task: Self { get }
        static var updates: [Self] { get }
    }
}

public extension ARKitSession.State {
    var dataProviders: [any DataProvider] { updates.map { $0.provider } }
}

public extension Reducer where State: ARKitSession.State, Action: ARKitSession.Action {
    static func task(state: State) -> Effect<Action> {
        return .run { [session = state.session, providers = state.dataProviders] send in
            try await session.run(providers)
            await withDiscardingTaskGroup { group in
                for updateAction in Action.updates {
                    _ = group.addTaskUnlessCancelled { await send(updateAction) }
                }
            }
        }
    }
}
#endif
