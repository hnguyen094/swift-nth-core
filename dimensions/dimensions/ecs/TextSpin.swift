//
//  TextSpin.swift
//  dimensions
//
//  Created by hung on 2/10/24.
//

import RealityKit
import ARKit

import SwiftUI

// actually, there actually might not be any good spin behavior.

enum TextSpin {
    static func register() {
        Component.registerComponent()
        System.registerSystem()
    }
    
    struct Component: RealityKit.Component {
        var alignment: PlaneAnchor.Alignment
    }
    
    struct System: RealityKit.System {
        static let query = EntityQuery(where: .has(Component.self))
        
        let arkitSession = ARKitSession()
        let worldData = WorldTrackingProvider()
        
        init(scene: RealityKit.Scene) {
            initSession()
        }
        
        func initSession() {
            Task {
                try? await arkitSession.run([worldData])
            }
        }
        
        func update(context: SceneUpdateContext) {
            let entities = context.scene.performQuery(Self.query).map({ $0 })
            
            guard !entities.isEmpty,
                  let pose = worldData.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else { return }

            let cameraTransform = Transform(matrix: pose.originFromAnchorTransform)


            for entity in entities {
                let component = entity.components[Component.self]!
                let upVector: SIMD3<Float> = switch component.alignment {
                case .horizontal: entity.position(relativeTo: .none) - cameraTransform.translation
                case .vertical: [0, 1, 0]
                @unknown default: [0, 1, 0]
                }

                entity.look(at: cameraTransform.translation,
                            from: entity.position(relativeTo: .none),
//                            upVector: upVector,
                            relativeTo: .none,
                            forward: .positiveZ)
            }
        }
    }
}
