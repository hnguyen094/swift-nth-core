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
    }
    
    struct System: RealityKit.System {
        static let query: EntityQuery = .init(where: .has(Component.self))
        
        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                let component = entity.components[Component.self]!

                guard let entityID = component.followeeID,
                      let followee = context.scene.findEntity(id: entityID)
                else { return }

                entity.setPosition(
                    followee.position(relativeTo: .none) + component.offset,
                    relativeTo: .none)
            }
        }
    }
}
