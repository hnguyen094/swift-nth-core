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
    }
    
    struct System: RealityKit.System {
        static let query: EntityQuery = .init(where: .has(Component.self))
        
        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                guard let entityID = entity.components[Component.self]!.followeeID,
                      let followee = context.scene.findEntity(id: entityID)
                else { return }

                entity.setPosition(followee.position(relativeTo: .none), relativeTo: .none)
            }
        }
    }
}
