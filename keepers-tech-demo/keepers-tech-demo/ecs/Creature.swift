//
//  Creature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import RealityKit

enum Creature {
    class Entity: RealityKit.Entity {
        
        @MainActor init(windowed: Bool) {
            super.init()
            initialConfiguration(windowed: windowed)
        }

        @MainActor required init() {
            super.init()
            initialConfiguration(windowed: true)
        }
        
        private func initialConfiguration(windowed: Bool) {
            let mesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .cyan, roughness: 0.5, isMetallic: true)

            let body = ModelEntity(mesh: mesh, materials: [material])
            body.name = "creature_body"
            body.components.set(Emoting.Component())
            
            if !windowed {
                body.generateCollisionShapes(recursive: true)
                // TODO: add movement components too, etc.
            }
            
            
            addChild(body)
        }
    }
}
