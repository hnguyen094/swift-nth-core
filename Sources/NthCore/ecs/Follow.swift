//
//  Follow.swift
//  keepers-tech-demo
//
//  Created by hung on 1/17/24.
//
#if os(visionOS)
import RealityKit

public enum Follow {
    public static func register() {
        Component.registerComponent()
        System.registerSystem()
    }
    
    public enum Mode: Codable {
        case direct
        case lazy(Float)
    }

    public struct Component: RealityKit.Component, Codable {
        public var followeeID: Entity.ID? = .none
        public var offset: SIMD3<Float> = .zero
        public var mode: Mode = .direct
        
        public init(followeeID: Entity.ID? = .none, offset: SIMD3<Float> = .zero, mode: Mode = .direct) {
            self.followeeID = followeeID
            self.offset = offset
            self.mode = mode
        }
        
        enum CodingKeys: CodingKey {
            case followeeID
            case offset
            case mode
        }
    }

    public struct System: RealityKit.System {
        static let query: EntityQuery = .init(where: .has(Component.self))
        
        public init(scene: Scene) { }
        
        public func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                let component = entity.components[Component.self]!
                let position = entity.position(relativeTo: .none)

                guard let entityID = component.followeeID,
                      let followee = context.scene.findEntity(id: entityID)
                else { return }

                // TODO: inconsistent behavior depending on anchored state (specifically rotation & scale)
                // TODO: follow should have a goal of not requiring reparenting
                if followee.isAnchored {
                    entity.setParent(followee, preservingWorldTransform: true)
                }

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
}
#endif
