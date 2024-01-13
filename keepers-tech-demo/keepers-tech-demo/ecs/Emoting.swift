//
//  Emoting.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import RealityKit

enum Emoting {
    struct Component: RealityKit.Component {
        var desiredAnimation: Animation = .idle

        fileprivate var current: IdentifiedAnimationController? = .none
    }
    
    struct System: RealityKit.System {
        static let query = EntityQuery(where: .has(Component.self))

        init(scene: Scene) {}
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                var component = entity.components[Component.self]!
                defer { entity.components.set(component) }

                var transform = entity.transform
                transform.translation = [0, 0, 0.4]
                
                if let current = component.current, !current.controller.isComplete { return }
                guard case .some(.some(let animation)) = Self.animations[.bounce] else { return }
                component.current = .init(
                    identifier: .bounce,
                    controller: entity.playAnimation(animation, transitionDuration: 0, startsPaused: false))
            }
        }
    }
}

extension Emoting.Component {
    struct IdentifiedAnimationController {
        let identifier: Emoting.Animation
        let controller: AnimationPlaybackController
    }
}
