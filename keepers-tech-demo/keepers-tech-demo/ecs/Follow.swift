//
//  Follow.swift
//  keepers-tech-demo
//
//  Created by hung on 1/17/24.
//

import RealityKit

enum Follow {
    struct Component: RealityKit.Component, Codable {
        var following: Entity.ID? = .none
    }
    
    struct System: RealityKit.System {
        static let query: EntityQuery = .init(where: .has(Component.self))
        
        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                guard let entityID = entity.components[Component.self]!.following,
                      let followingEntity = context.scene.findEntity(id: entityID)
                else { return }

                entity.setPosition(followingEntity.position(relativeTo: .none), relativeTo: .none)
            }
        }
    }
}
