//
//  WorldAnchoring.swift
//  dimensions
//
//  Created by hung on 2/10/24.
//

import ComposableArchitecture
import ARKit
import RealityKit

@Reducer
struct WorldAnchoring {
    @ObservableState
    struct State {
        var transforms: [Entity.ID: simd_float4x4] = .init()
        var associations: [WorldAnchor.ID : Entity.ID] = .init()
    }
    
    let arSession = ARKitSession()
    let worldData = WorldTrackingProvider()
    
    enum Action {
        case onStart
        case handleUpdate(AnchorUpdate<WorldAnchor>)
        case register(_ entity: Entity)
        case onEnd
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onStart:
                return .run { send in
                    try await arSession.run([worldData])
                    for await update in worldData.anchorUpdates {
                        await send(.handleUpdate(update))
                    }
                }
            case .handleUpdate(let update):
                switch update.event {
                case .added, .updated:
                    guard let associatedEntityID = state.associations[update.anchor.id] else {
                        // if missing, it is from previous session; do nothing
                        break
                    }
                    state.transforms[associatedEntityID] = update.anchor.originFromAnchorTransform
                case .removed:
                    // TODO: in a different room now, need to register new entity?
                    break
                }
                return .none
            case .register(let entity):
                let transform = entity.transformMatrix(relativeTo: .none)
                let anchor = WorldAnchor(originFromAnchorTransform: transform)
                state.associations.updateValue(entity.id, forKey: anchor.id)
                return .run { send in
                    try await worldData.addAnchor(anchor)
                }
            case .onEnd:
                arSession.stop()
                return .none
            }
        }
    }
}
