//
//  Demo.swift
//  keepers-tech-demo
//
//  Created by hung on 1/24/24.
//

import RealityKit

enum Demo {
    struct Component: RealityKit.Component, Codable {
        var desiredMode: Mode? = .animations
        
        fileprivate var currentMode: Mode? = .none
        fileprivate var restorable: Restorable? = .none
        fileprivate var modeDuration: Double = 0
        
        enum CodingKeys: CodingKey {  case desiredMode }
    }
    
    struct System: RealityKit.System {
        static let query = EntityQuery(where: .has(Component.self))
        
        init(scene: Scene) { }
        
        func update(context: SceneUpdateContext) {
            context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                var component = entity.components[Component.self]!
                guard let creature = entity as? Creature.Entity,
                      let creatureBody = creature.body
                else { return }
                defer {
                    component.currentMode = component.desiredMode
                    entity.components.set(component)
                }
                component.modeDuration += context.deltaTime
                let requireTransition = component.desiredMode != component.currentMode
                
                if requireTransition {
                    if case .none = component.currentMode {
                        save(&component, creature: creature, creatureBody: creatureBody)
                    } else {
                        restore(component, creature: creature, creatureBody: creatureBody)
                    }
                    // TODO: actually transition; maybe uncessary?

                    component.modeDuration = 0
                } else { // handle the frame-by-frame of the current animation.
                    switch component.desiredMode {
                    case .animations:
                        creatureBody.components[Emoting.Component.self]?.desiredAnimation = .excitedBounce
                        guard var bodyComponent = creatureBody.components[Creature.Body.Component.self]
                        else { break }
                        let hue = component.modeDuration.truncatingRemainder(dividingBy: 10) / 10
                        bodyComponent.desiredColor = Creature.Backing.Color(
                            hue: hue,
                            saturation: 1,
                            brightness: 1
                        ).toColorData()
                        let squareness = sin(Float(component.modeDuration / 2)) / 2 + 0.5
                        bodyComponent.desiredSquareness = squareness
                        creatureBody.components.set(bodyComponent)
                    case .anchorUnderstanding:
                        break
                    case .soundUnderstanding:
                        break
                    case .worldAndHandUnderstanding:
                        break
                    case .none: // state is already restored; do nothing
                        break
                    }
                }
            }
        }
        
        private func save(_ component: inout Component, creature: Creature.Entity, creatureBody: Entity) {
            component.restorable = .init(
                emoting: creatureBody.components[Emoting.Component.self]?.desiredAnimation,
                squareness: creatureBody.components[Creature.Body.Component.self]!.desiredSquareness,
                color: creatureBody.components[Creature.Body.Component.self]!.desiredColor,
                anchor: creature.components[AnchoringComponent.self]?.target)
        }

        private func restore(_ component: Component, creature: Creature.Entity, creatureBody: Entity) {
            guard let restorable = component.restorable else { return }
            if let emoting = restorable.emoting {
                creatureBody.components[Emoting.Component.self]?.desiredAnimation = emoting
            }
            creatureBody.components[Creature.Body.Component.self]!.desiredSquareness = restorable.squareness
            creatureBody.components[Creature.Body.Component.self]!.desiredColor = restorable.color
            if let anchorTarget = restorable.anchor {
                creature.components[AnchoringComponent.self] = AnchoringComponent(anchorTarget)
            }
        }
    }
    
    struct Restorable {
        var emoting: Emoting.Animation?
        var squareness: Float
        var color: ColorData
        var anchor: AnchoringComponent.Target? // Note: not caring about TrackingMode, could be problem
//        var transform: Transform
    }
    
    enum Mode: CaseIterable, Codable, Hashable {
        case animations
        case anchorUnderstanding
        case soundUnderstanding
        case worldAndHandUnderstanding
    }
}
