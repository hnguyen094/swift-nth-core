//
//  PlaneMeasure.swift
//  dimensions
//
//  Created by hung on 2/9/24.
//

import ComposableArchitecture
import ARKit
import RealityKit

@Reducer
struct PlaneMeasure {
    @ObservableState
    struct State {
        var labels: [ID: Label] = .init()
        var offset: SIMD3<Float> = [0, 0, 0.01]
    }
    
    let arSession = ARKitSession()
    let planeData = PlaneDetectionProvider()

    enum Action {
        case onStart(PlaneVisualization.Configuration)
        case handleUpdate(AnchorUpdate<PlaneAnchor>)
        case onEnd
    }
    
    @Dependency(\.planeEntities) var planeEntities
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onStart(let config):
                return .run { send in
                    await planeEntities.initialize(config)
                    try await arSession.run([planeData])
                    for await update in planeData.anchorUpdates {
                        await send(.handleUpdate(update))
                    }
                }
            case .handleUpdate(let update):
                generateLabels(&state, from: update)
                return .run { _ in                    
                    await planeEntities.update(update: update)
                }
            case .onEnd:
                state.labels.removeAll(keepingCapacity: true)
                arSession.stop()
                return .run { _ in
                    await planeEntities.clear()
                }
            }
        }
    }
    
    func generateLabels(_ state: inout State, from update: AnchorUpdate<PlaneAnchor>) {
        let extent = update.anchor.geometry.extent

        switch update.event {
        case .added, .updated:
            for edge in Edge.allCases {
                let measurement: Float = switch edge {
                case .top, .bottom: extent.width
                case .left, .right: extent.height
                }
                var translation: SIMD3<Float> = switch edge {
                case .top: [0, extent.height/2, 0]
                case .bottom: [0, -extent.height/2, 0]
                case .left: [-extent.width/2, 0, 0]
                case .right: [extent.width/2, 0, 0]
                }
                translation += state.offset
                let rotation: simd_quatf = switch edge {
                case .top, .bottom: .init(angle: 0, axis: [0, 1, 0])
                case .left: .init(angle: .pi / 2, axis: [0, 0, 1])
                case .right: .init(angle: .pi / 2, axis: [0, 0, -1])
                }
                
                let offset = Transform(rotation: rotation, translation: translation)
                let planeSpace = extent.anchorFromExtentTransform * offset.matrix
                let worldSpace = update.anchor.originFromAnchorTransform * planeSpace
                state.labels.updateValue(
                    .init(
                        measurement: measurement,
                        transform: worldSpace,
                        alignment: update.anchor.alignment,
                        classification: update.anchor.classification),
                    forKey: .init(
                        anchorID: update.anchor.id,
                        edge: edge))
            }
        case .removed:
            for edge in Edge.allCases {
                state.labels.removeValue(forKey: .init(
                    anchorID: update.anchor.id,
                    edge: edge))
            }
        }
    }

    struct Label {
        var measurement: Float
        var transform: simd_float4x4
        var alignment: PlaneAnchor.Alignment
        var classification: PlaneAnchor.Classification

        func label(metric usesMetricSystem: Bool) -> String {
            let value = measurement * (usesMetricSystem ? 1 : 3.28084)
            let unit = usesMetricSystem ? "m" : "ft"
            let prefix = "[\(classification)] "

            return prefix + String(format: "%.2f", value) + unit
        }
    }
    
    struct ID: Hashable {
        let anchorID: PlaneAnchor.ID
        let edge: Edge
    }

    enum Edge: CaseIterable {
        case top
        case bottom
        case left
        case right
    }
}
