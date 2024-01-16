//
//  Billboard.swift
//  keepers-tech-demo
//
//  Created by hung on 1/15/24.
//

import RealityKit
import Dependencies

import UIKit

enum Billboard {
    struct Component: RealityKit.Component {
        var mode: Mode
    }

    struct System: RealityKit.System {
        @Dependency(\.arkitSessionManager.worldTrackingData) var worldTrackingData
        @Dependency(\.windowed) var isWindowed
        
        static let query = EntityQuery(where: .has(Component.self))

        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            print(isWindowed)
            guard let deviceAnchor = worldTrackingData?
                .queryDeviceAnchor(atTimestamp: CACurrentMediaTime()),
                  deviceAnchor.isTracked
            else { return }
            let deviceTransform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
            
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                let mode = entity.components[Component.self]!.mode
                var transform = entity.transform

//                entity.convert(transform: <#T##Transform#>, to: <#T##Entity?#>)
                
                print("\(deviceTransform.translation), \(entity.position(relativeTo: nil))")
                
                entity.look(at: deviceTransform.translation, from: entity.position(relativeTo: nil), relativeTo: nil)
                if case .direct = mode { return }
                defer { entity.transform = transform }
                
                guard case .lazy(let value) = mode else { return } // TODO: log issue, missing impl
                transform.rotation = simd_slerp(transform.rotation, entity.transform.rotation, Float(context.deltaTime * value))
            }
        }
    }
}

extension Billboard {
    enum Mode {
        case direct
        case lazy(Double)
    }
}
