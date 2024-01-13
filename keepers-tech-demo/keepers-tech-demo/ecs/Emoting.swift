//
//  Emoting.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import RealityKit

enum Emoting {
    struct Component: RealityKit.Component {
        var desiredAnimation: Animation = .excitedBounce
        fileprivate var current: IdentifiedAnimationController? = .none
    }
    
    struct System: RealityKit.System {
        static let query = EntityQuery(where: .has(Component.self))

        init(scene: Scene) {}
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                var component = entity.components[Component.self]!
                defer { entity.components.set(component) }
                
                if let current = component.current, current.identifier == component.desiredAnimation, !current.controller.isComplete { return }
                // we now need to identify what we need to do.
                // if current is nil, we start our desired animation
                // if identifier is desired (but controller is completed), we TODO it
                // if identifier is NOT desired, we transition
                // if idtentifier is transition, wait for it to complete
                // if identifier is transition, and it is complete, we start our desired animation
                
                guard let current = component.current else {
                    startDesiredAnimation(&component, entity: entity)
                    return
                }
                
                switch (current.identifier, current.controller.isComplete) {
                case (.transitioning, true):
                    startDesiredAnimation(&component, entity: entity)
                case let (currentAnimation, true) where currentAnimation == component.desiredAnimation:
                    // TODO: What to do when desired animation completes.
                    break
                case let (currentAnimation, _) where currentAnimation != component.desiredAnimation && currentAnimation != .transitioning:
                    current.controller.stop() // TODO: stop with blendout? need to wait for completion?
                    startTransitionAnimation(&component, entity: entity)
                default:
                    break
                }
                
            }
        }
        
        private func startDesiredAnimation(_ component: inout Component, entity: Entity) {
            guard case .some(.some(let animation)) = Self.animations[component.desiredAnimation] else { return }
            print("New animation started")
            component.current = .init(
                identifier: component.desiredAnimation,
                controller: entity.playAnimation(animation.repeat(), transitionDuration: 0, startsPaused: false))
        }
        
        private func startTransitionAnimation(_ component: inout Component, entity: Entity) {
            guard case .some(let animation) = Self.returnAnimation(from: entity.transform) else { return }
            print("Return animation started")
            component.current = .init(
                identifier: .transitioning,
                controller: entity.playAnimation(animation, transitionDuration: 0, startsPaused: false))
        }
    }
}

extension Emoting.Component {
    struct IdentifiedAnimationController {
        let identifier: Emoting.Animation
        let controller: AnimationPlaybackController
    }
}
