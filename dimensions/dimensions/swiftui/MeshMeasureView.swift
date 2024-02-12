//
//  MeshMeasureView.swift
//  dimensions
//
//  Created by hung on 2/12/24.
//

import SwiftUI
import ComposableArchitecture
import RealityKit
import RealityKitContent

struct MeshMeasureView: View {
    @Bindable var store: StoreOf<MeshMeasure>
    @Binding var usesMetricSystem: Bool

    let config: MeshVisualization.Configuration = .init(
        root: Entity(),
        material: SimpleMaterial(color: .blue, isMetallic: false))

    var tap: some Gesture {
        SpatialTapGesture()
            .targetedToEntity(where: .has(SceneUnderstandingComponent.self))
            .onEnded { event in
                let position = event.convert(event.location3D, from: .local, to: .scene)
                store.send(.addPoint(position))
            }
    }

    var body: some View {
        RealityView { content, attachments in
            content.add(config.root)
            addAttachments(&content, attachments)
        } update: { content, attachments in
            addAttachments(&content, attachments)
        } attachments: {
            ForEach(Array(store.measurements.keys), id: \.self) { key in
                Attachment(id: key) {
                    Text(store.measurements[key]!.label(metric: usesMetricSystem))
                        .padding()
                        .glassBackgroundEffect()
                }
            }
        }
        .task {
            store.send(.onStart(config))
        }
        .onDisappear {
            store.send(.onEnd)
        }
        .gesture(tap)
    }

    func addAttachments(_ content: inout RealityViewContent, _ attachments: RealityViewAttachments) {
        for (key, value) in store.measurements {
            guard let attachment = attachments.entity(for: key),
                  case .complete(let p1, let p2) = value
            else { continue }

            let middle = p1 + (p2 - p1) / 2
            // could face wrong way, using origin for now
            // TODO: could use users' head to identify instead
            let facingDirection = simd_cross([0, 1, 0], simd_fast_normalize(p2 - p1))

            let orientedFacingDirection = switch simd_dot(simd_fast_normalize(middle), facingDirection) {
            case let x where x > 0: -facingDirection
            default: facingDirection
            }

            let rotation = simd_quatf(from: [0, 0, 1], to: orientedFacingDirection)
            attachment.transform.rotation = rotation
            attachment.setPosition(middle, relativeTo: .none)
            attachment.components.set(GroundingShadowComponent(castsShadow: true))

            for i in 0..<2 {
                let entity = ModelEntity(mesh: .generateSphere(radius: 0.005), materials: [UnlitMaterial(color: .accentColor)])
                entity.setPosition(i == 0 ? p1 : p2, relativeTo: .none)
                attachment.addChild(entity, preservingWorldTransform: true)
            }

            content.add(attachment)
        }
    }

}

#Preview {
    MeshMeasureView(store: .init(initialState: .init(), reducer: {
        MeshMeasure()
    }), usesMetricSystem: .constant(true))
    .previewLayout(.sizeThatFits)
}
