//
//  Follow.swift
//  keepers-tech-demo
//
//  Created by hung on 1/17/24.
//

import RealityKit

enum Follow {
    struct Component: RealityKit.Component, Codable {
        var followeeID: Entity.ID? = .none
        var offset: SIMD3<Float> = .zero
        var mode: Mode = .direct
        
        enum CodingKeys: CodingKey {
            case followeeID
            case offset
            case mode
        }
    }
    
    struct System: RealityKit.System {
        static let query: EntityQuery = .init(where: .has(Component.self))
        
        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                let component = entity.components[Component.self]!
                let position = entity.position(relativeTo: .none)

                guard let entityID = component.followeeID,
                      let followee = context.scene.findEntity(id: entityID)
                else { return }
                
                // necessary since followee might be in the anchor hierarchy instead. Yuck.
                // maybe there's a way to identify and also anchor the follower, but.
                entity.setParent(followee.parent, preservingWorldTransform: true)

                let targetPosition = followee.position(relativeTo: .none) + component.offset
                
                switch component.mode {
                case .direct:
                    entity.setPosition(targetPosition, relativeTo: .none)
                case .lazy(let value):
                    let lazyValue = Float(context.deltaTime) * value
                    entity.setPosition(position + (targetPosition - position) * lazyValue, relativeTo: .none)
                }
            }
        }
    }
    enum Mode: Codable {
        case direct
        case lazy(Float)
    }
}
