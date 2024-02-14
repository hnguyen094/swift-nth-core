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

    let line = ModelEntity(
        mesh: .generateBox(width: 0.005, height: 1, depth: 0.005, cornerRadius: 0.005),
        materials: [UnlitMaterial(color: .accentColor)])
    let dot = ModelEntity(
        mesh: .generateSphere(radius: 0.005),
        materials: [UnlitMaterial(color: .accentColor)])

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
            await addMaterialStore(&content)
            addAttachments(&content, attachments)
        } update: { content, attachments in
            addAttachments(&content, attachments)
        } attachments: {
            ForEach(Array(store.measurements.keys), id: \.self) { key in
                Attachment(id: key) {
                    let label = store.measurements[key]!.label(metric: usesMetricSystem)
                    Text(label)
                        .padding()
                        .glassBackgroundEffect()
                        .animation(.default, value: label)
                }
            }
        }
        .onAppear { store.send(.onStart(config)) }
        .onDisappear { store.send(.onEnd) }
        .gesture(tap)
    }

    enum NamedEntity: String {
        case materialStore
    }

    @MainActor
    func addMaterialStore(_ content: inout RealityViewContent) async {
        let material = try? await ShaderGraphMaterial(
            named: "/Root/Glow",
            from: "Materials/Glow",
            in: realityKitContentBundle)
        let materialStore = dot.clone(recursive: false)
        materialStore.isEnabled = false
        materialStore.name = NamedEntity.materialStore.rawValue
        materialStore.model?.materials = [material ?? UnlitMaterial(color: .white)]
        content.add(materialStore)
    }

    @MainActor
    func addAttachments(_ content: inout RealityViewContent, _ attachments: RealityViewAttachments) {
        for (key, value) in store.measurements {
            guard let attachment = attachments.entity(for: key) else { continue }

            let parent = attachment.parent ?? Entity()
            attachment.setParent(parent)

            attachment.move(to: localAttachmentTransform(value), relativeTo: .none, duration: 1)
            attachment.transform = localAttachmentTransform(value)
            attachment.components.set(GroundingShadowComponent(castsShadow: true))

            addPoints(value, to: parent, content: &content)

            content.add(parent)
        }
    }

    func localAttachmentTransform(_ pair: MeshMeasure.Pair) -> Transform {
        switch pair {
        case .partial(let point):
            return .init(translation: point + [0, 0.01, 0])
        case .complete(let p1, let p2):
            let middle = p1 + (p2 - p1) / 2
            // could face wrong way, using origin for now
            // TODO: could use users' head to identify instead
            let facingDirection = simd_cross([0, 1, 0], simd_fast_normalize(p2 - p1))

            let orientedFacingDirection = switch simd_dot(simd_fast_normalize(middle), facingDirection) {
            case let x where x > 0: -facingDirection
            default: facingDirection
            }

            let rotation = simd_quatf(from: [0, 0, 1], to: orientedFacingDirection)
            return .init(rotation: rotation, translation: middle)
        }
    }

    func addPoints(_ pair: MeshMeasure.Pair, to parent: Entity, content: inout RealityViewContent) {
        let materialStore = content.entities.first { entity in
            entity.name == NamedEntity.materialStore.rawValue
        }
        let material = materialStore?.components[ModelComponent.self]?.materials.first

        let points: [SIMD3<Float>] = switch pair {
        case .partial(let p): [p]
        case .complete(let p1, let p2): [p1, p2]
        }

        let pointParent = {
            if let existing = parent.findEntity(named: "points") {
                return existing
            }
            let newParent = Entity()
            newParent.name = "points"
            parent.addChild(newParent)
            return newParent
        }()

        if pointParent.children.count == 2 { return }
        pointParent.children.removeAll()

        for point in points {
            let entity = dot.clone(recursive: false)
            entity.name = "point"
            if let custom = material {
                entity.model!.materials = [custom]
            }
            entity.setPosition(points.first!, relativeTo: .none)
            pointParent.addChild(entity, preservingWorldTransform: true)
            entity.move(to: Transform(translation: point), relativeTo: .none, duration: 1)
        }
//            let idk = simd_cross(simd_fast_normalize(p2 - p1), [0, 1, 0])
//            let entity = ModelEntity(mesh: lineMesh, materials: [material ?? UnlitMaterial(color: .white)])
//            entity.setPosition(middle, relativeTo: .none)
//            entity.setScale([1, simd_distance(p2, p1), 1], relativeTo: .none)
//            entity.transform.rotation = .init(from: [0, 0, 1], to: idk)  * .init(angle: .pi / 2, axis: [0, 0, 1])
//            attachment.addChild(entity, preservingWorldTransform: true)
    }
}

#Preview {
    MeshMeasureView(store: .init(initialState: .init(), reducer: {
        MeshMeasure()
    }), usesMetricSystem: .constant(true))
    .previewLayout(.sizeThatFits)
}
