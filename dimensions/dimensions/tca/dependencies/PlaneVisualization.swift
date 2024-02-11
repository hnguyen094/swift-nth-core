//
//  PlaneVisualization.swift
//  dimensions
//
//  Created by hung on 2/9/24.
//

import Dependencies
import DependenciesMacros

import RealityKit
import ARKit

extension DependencyValues {
    var planeEntities: PlaneVisualization {
        get { self[PlaneVisualization.self] }
        set { self[PlaneVisualization.self] = newValue }
    }
}

@DependencyClient
struct PlaneVisualization {
    var initialize: (Configuration) -> Void
    var update: (_ update: AnchorUpdate<PlaneAnchor>) async -> Void
    var clear: () -> Void
    
    struct Configuration {
        var root: Entity
        var mesh: MeshResource
        var material: Material
    }
}

extension PlaneVisualization: DependencyKey {
    static let testValue: Self = .init()
    static let previewValue: Self = .init()
    static var liveValue: Self {
        var configuration: Configuration? = .none
        var entities: [PlaneAnchor.ID: ModelEntity] = .init()
        
        return .init(
            initialize: { config in
                configuration = config
            }, update: { update in
                guard let config = configuration else { return }

                let extent = update.anchor.geometry.extent
                switch update.event {
                case .added:
                    let entity = await ModelEntity(mesh: config.mesh, materials: [ config.material])
                    let local = Transform(scale: [extent.width, extent.height, 1])
                    let extentTransform = update.anchor.originFromAnchorTransform * extent.anchorFromExtentTransform * local.matrix
                    await entity.setTransformMatrix(extentTransform, relativeTo: .none)
                    await entity.setScale([extent.width, extent.height, 1], relativeTo: .none)
                    await entity.setParent(config.root, preservingWorldTransform: true)
                case .updated:
                    guard let entity = entities[update.anchor.id] else { return }
                    await entity.setScale([extent.width, extent.height, 1], relativeTo: .none)
                case .removed:
                    guard let entity = entities[update.anchor.id] else { return }
                    await entity.removeFromParent()
                    entities.removeValue(forKey: update.anchor.id)
                }
            }, clear: {
                guard let config = configuration else { return }
                entities.removeAll(keepingCapacity: true)
                config.root.children.removeAll()
            })
    }
}
