//
//  Billboard.swift
//  keepers-tech-demo
//
//  Created by hung on 1/15/24.
//

import RealityKit
import Dependencies

import UIKit

public enum Billboard {
    public static func register() {
        Component.registerComponent()
        System.registerSystem()
    }

    public enum Mode: Codable {
        case direct
        case lazy(Double)
    }

    public struct Component: RealityKit.Component, Codable {
        public var mode: Mode
        
        public init(mode: Mode) {
            self.mode = mode
        }
    }

    public struct System: RealityKit.System {
        @Dependency(\.arkitSessionManager.worldTrackingData) var worldTrackingData
        @Dependency(\.logger) var logger
        
        static let query = EntityQuery(where: .has(Component.self))

        public init(scene: Scene) { }
        
        public func update(context: SceneUpdateContext) {
            let entities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)

            guard case .some = entities.first(where: {_ in true }),
                  let deviceAnchor = worldTrackingData?
                .queryDeviceAnchor(atTimestamp: CACurrentMediaTime()),
                  deviceAnchor.isTracked
            else { return }
            let deviceTransform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
            
            for entity in entities {
                let mode = entity.components[Component.self]!.mode
                var transform = entity.transform
                
                logger.debug("\(deviceTransform.translation), \(entity.position(relativeTo: nil))")
                
                entity.look(at: deviceTransform.translation, 
                            from: entity.position(relativeTo: nil),
                            relativeTo: nil,
                            forward: .positiveZ)
                if case .direct = mode { return }
                defer { entity.transform = transform }
                
                guard case .lazy(let value) = mode else {
                    logger.error("Missing implementation for \(String(describing: mode)) in billboard system.")
                    return
                } // TODO: log issue, missing impl
                transform.rotation = simd_slerp(transform.rotation, entity.transform.rotation, Float(context.deltaTime * value))
            }
        }
    }
}
