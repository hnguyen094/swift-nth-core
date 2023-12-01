//
//  WorldTrackerDebug.swift
//  keepers-together
//
//  Created by Hung on 11/30/23.
//

import ComposableArchitecture

@Reducer
struct WorldTrackerDebug: Reducer {
    @Dependency(\.worldTracker) var worldTracker
    struct State: Equatable { 
        var output: String = ""
    }
    
    enum Action {
        case runARSession
        case toggleWorldTracking(Bool)
        case togglePlaneTracking(Bool)
        case toggleMeshTracking(Bool)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .runARSession:
            return .run { _ in
                await worldTracker.run()
            }
        case .toggleMeshTracking(let toggle):
            return .run { _ in
                await worldTracker.beginMeshAnchorUpdates()
            }
        case .togglePlaneTracking(let toggle):
            return .run { _ in
                await worldTracker.beginPlaneAnchorUpdates()
            }
        case .toggleWorldTracking(let toggle):
            return .run { _ in
                await worldTracker.beginWorldAnchorUpdates()
            }
        }
    }
}
