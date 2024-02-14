//
//  MeshVisualization.swift
//  dimensions
//
//  Created by hung on 2/12/24.
//

import Dependencies
import DependenciesMacros

import RealityKit
import ARKit

extension DependencyValues {
    var meshEntities: MeshVisualization {
        get { self[MeshVisualization.self] }
        set { self[MeshVisualization.self] = newValue }
    }
}

@DependencyClient
struct MeshVisualization {
    var initialize: (Configuration) async -> Void
    var update: (_ update: AnchorUpdate<MeshAnchor>) async -> Void
    var clear: () async -> Void

    struct Configuration {
        var root: Entity
        var material: Material
    }
}

extension MeshVisualization: DependencyKey {
    static let testValue: Self = .init()
    static let previewValue: Self = .init()
    static var liveValue: Self {
        var configuration: Configuration? = .none
        var entities: [MeshAnchor.ID: ModelEntity]? = .none

        return .init { @MainActor config in
            configuration = config
            entities = .init()
        } update: { @MainActor update in
            guard let config = configuration,
                  let shape = try? await ShapeResource.generateStaticMesh(from: update.anchor)
            else { return }

            switch update.event {
            case .added:
                let entity = ModelEntity()
                // TODO: create mesh, create occlusion material
                entity.setTransformMatrix(update.anchor.originFromAnchorTransform, relativeTo: .none)
                entity.components.set(CollisionComponent(shapes: [shape], isStatic: true))
                entity.components.set(InputTargetComponent())
                entity.components.set(SceneUnderstandingComponent())
                entity.components.set(PhysicsBodyComponent(mode: .static))
                entity.components.set(HoverEffectComponent())
                entity.setParent(config.root, preservingWorldTransform: true)

                entities?[update.anchor.id] = entity
            case .updated:
                guard let entity = entities?[update.anchor.id] else { return }
                entity.setTransformMatrix(update.anchor.originFromAnchorTransform, relativeTo: .none)
                entity.components.set(CollisionComponent(shapes: [shape], isStatic: true))
            case .removed:
                guard let entity = entities?[update.anchor.id] else { return }
                entity.removeFromParent()
                entities?.removeValue(forKey: update.anchor.id)
            }
        } clear: { @MainActor in
            guard let config = configuration else { return }
            entities?.removeAll(keepingCapacity: true)
            config.root.children.removeAll()
        }

    }

}
