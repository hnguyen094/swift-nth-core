//
//  ExcitementBounceSystem.swift
//  keepers
//
//  Created by Hung on 9/22/23.
//

import RealityKit

extension AppSystem {
    struct SimpleBounce : System {
        private static let query = EntityQuery(where: .has(AppComponent.Bounce.self))
        
        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            context.scene.performQuery(Self.query).forEach { entity in
                var c = entity.components[AppComponent.Bounce.self] as! AppComponent.Bounce
                c.elapsedTime += Float(context.deltaTime)
                entity.components[AppComponent.Bounce.self] = c
                entity.transform.translation.y = c.amplitude * sin(c.elapsedTime)
            }
        }
    }
}

extension AppComponent {
    struct Bounce: Component {
        var amplitude: Float
        var elapsedTime: Float
    }
}
