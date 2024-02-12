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

// TODO: This might need to be an actor, with protocols, instead.
@DependencyClient
struct PlaneVisualization {
    var initialize: (Configuration) async -> Void
    var update: (_ update: AnchorUpdate<PlaneAnchor>) async -> Void
    var clear: () async -> Void

    struct Configuration {
        var root: Entity
        var mesh: MeshResource
        var material: Material
    }
}

extension PlaneVisualization: DependencyKey {
    static let testValue: Self = .init()
    static let previewValue: Self = .init()
    static let liveValue: Self = lines
    
    static var rectangles: Self {
        var configuration: Configuration? = .none
        var entities: [PlaneAnchor.ID: ModelEntity]? = .none

        return .init(
            initialize: { config in
                configuration = config
                entities = .init()
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
                    entities?[update.anchor.id] = entity
                case .updated:
                    guard let entity = entities?[update.anchor.id] else { return }
                    await entity.setScale([extent.width, extent.height, 1], relativeTo: .none)
                case .removed:
                    guard let entity = entities?[update.anchor.id] else { return }
                    await entity.removeFromParent()
                    entities?.removeValue(forKey: update.anchor.id)
                }
            }, clear: {
                guard let config = configuration else { return }
                entities?.removeAll(keepingCapacity: true)
                await config.root.children.removeAll()
            })
    }
    
    static var lines: Self {
        var configuration: Configuration? = .none
        var entities: [PlaneMeasure.ID: ModelEntity]? = .none

        return .init { config in
            configuration = config
            entities = .init()
        } update: { update in
            guard let config = configuration else { return }

            let extent = update.anchor.geometry.extent
            for edge in PlaneMeasure.Edge.allCases {
                let id = PlaneMeasure.ID(anchorID: update.anchor.id, edge: edge)
                switch update.event {
                case .added:
                    let entity = await ModelEntity(mesh: config.mesh, materials: [config.material])
                    let extentTransform = update.anchor.originFromAnchorTransform * extent.anchorFromExtentTransform * computeLocalTransform(extent: extent, edge: edge)
                    await entity.setTransformMatrix(extentTransform, relativeTo: .none)
                    await entity.setParent(config.root, preservingWorldTransform: true)
                    entities?[id] = entity
                case .updated:
                    guard let entity = entities?[id] else { return }

                    let extentTransform = update.anchor.originFromAnchorTransform * extent.anchorFromExtentTransform * computeLocalTransform(extent: extent, edge: edge)
                    await entity.setTransformMatrix(extentTransform, relativeTo: .none)
                case .removed:
                    guard let entity = entities?[id] else { return }
                    await entity.removeFromParent()
                    entities?.removeValue(forKey: id)
                }
            }
        } clear: {
            guard let config = configuration else { return }
            entities?.removeAll(keepingCapacity: true)
            await config.root.children.removeAll()
        }

        func computeLocalTransform(extent: PlaneAnchor.Geometry.Extent, edge: PlaneMeasure.Edge) -> simd_float4x4 {
            let scale: SIMD3<Float> = switch edge {
            case .top, .bottom: [1, extent.width, 1]
            case .left, .right: [1, extent.height, 1]
            }
            let rotation: simd_quatf = switch edge {
            case .top, .bottom: .init(angle: .pi / 2, axis: [0, 0, 1])
            case .left, .right: .init(angle: 0, axis: .one)
            }
            let translation: SIMD3<Float> = switch edge {
            case .top: [0, extent.height/2, 0]
            case .bottom: [0, -extent.height/2, 0]
            case .left: [-extent.width/2, 0, 0]
            case .right: [extent.width/2, 0, 0]
            }

            let local = Transform(scale: scale, rotation: rotation, translation: translation)
            return local.matrix
        }
    }
}
