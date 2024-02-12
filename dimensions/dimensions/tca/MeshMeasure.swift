//
//  MeshMeasure.swift
//  dimensions
//
//  Created by hung on 2/12/24.
//

import ComposableArchitecture
import ARKit
import RealityKit

@Reducer
struct MeshMeasure {
    @ObservableState
    struct State {
        var measurements: [UUID: Pair] = .init()
        var offset: SIMD3<Float> = [0, 0, 0.01]
        var current: Pair? = .none
    }

    enum Pair {
        case partial(SIMD3<Float>)
        case complete(SIMD3<Float>, SIMD3<Float>)

        func label(metric usesMetricSystem: Bool) -> String {
            guard case .complete(let p1, let p2) = self else {
                return "[measuring]"
            }
            let measurement = simd_distance(p1, p2)
            let value = measurement * (usesMetricSystem ? 1 : 3.28084)
            let unit = usesMetricSystem ? "m" : "ft"

            return String(format: "%.2f", value) + unit
        }
    }

    let arSession = ARKitSession()
    let meshData = SceneReconstructionProvider()

    enum Action {
        case onStart(MeshVisualization.Configuration)
        case handleUpdate(AnchorUpdate<MeshAnchor>)
        case addPoint(SIMD3<Float>)
        case onEnd
    }

    @Dependency(\.uuid) var uuid
    @Dependency(\.meshEntities) var meshEntities

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onStart(let config):
                return .run { send in
                    await meshEntities.initialize(config)
                    try await arSession.run([meshData])
                    for await update in meshData.anchorUpdates {
                        await send(.handleUpdate(update))
                    }
                }
            case .handleUpdate(let update):
                return .run { _ in
                    await meshEntities.update(update: update)
                }
            case .addPoint(let point):
                switch state.current {
                case .partial(let first):
                    state.current = .complete(first, point)
                    state.measurements[uuid()] = state.current
                case .none, .complete:
                    state.current = .partial(point)
                }
                return .none
            case .onEnd:
                state.measurements.removeAll()
                state.current = .none
                arSession.stop()
                return .run { _ in
                    await meshEntities.clear()
                }
            }
        }
    }
}
