//
//  Follow.swift
//  keepers-tech-demo
//
//  Created by hung on 1/17/24.
//
import RealityKit
import NthCommon

/// Might reparent the follower to match the same entity hierarchy when the followee is anchored.
public enum Follow {
    @MainActor
    public static func register() {
        Component.registerComponent()
        System.registerSystem()
    }
    
    public enum Mode: Codable {
        case direct
        case lazy(Float)

        public static var lazy: Self { .lazy(1) }
    }

    public struct Component: RealityKit.Component, Codable {
        public var followeeID: Entity.ID? = .none
        public var followerTransform: Transform = .identity
        public var mode: Mode = .direct

        public init(
            following: Entity? = .none,
            transform: Transform = .identity,
            mode: Mode = .direct
        ) {
            self.followeeID = following?.id
            self.followerTransform = transform
            self.mode = mode
        }
    }

    // TODO: keepers-tech-demo callers might be wrong since we have added rotation/scaling (s)lerp
    public struct System: RealityKit.System {
        let query: EntityQuery = .init(where: .has(Component.self))

        public init(scene: Scene) { }
        
        public func update(context: SceneUpdateContext) {
            context.entities(matching: query, updatingSystemWhen: .rendering).forEach { follower in
                let component = follower.components[Component.self]!

                guard let entityID = component.followeeID,
                      let followee = context.scene.findEntity(id: entityID)
                else { return }

                // Reparenting is inevitable due to how some anchor entities will hide its transform
                // TODO: possible inconsistent rotation/scale behavior when anchored
                if followee.isAnchored {
                    follower.setParent(followee.anchor, preservingWorldTransform: true)
                }
                let current = Transform(matrix: follower.transformMatrix(relativeTo: .none))
                let target = followee.convert(
                    transform: component.followerTransform,
                    to: .none
                )

                switch component.mode {
                case .direct:
                    follower.setTransformMatrix(target.matrix, relativeTo: .none)
                case .lazy(let value):
                    let lazyValue = Float(context.deltaTime) * value
                    follower.setTransformMatrix(
                        current.lerp(to: target, t: lazyValue).matrix,
                        relativeTo: .none
                    )
                }
            }
        }
    }
}
