//
//  Creature.Body.swift
//  keepers-tech-demo
//
//  Created by hung on 1/24/24.
//

import RealityKit
import NthCore

extension Creature {
    enum Body {
        public static func register() {
            Component.registerComponent()
            System.registerSystem()
        }

        struct Component: RealityKit.Component, Codable {
            var desiredColor: ColorData
            var desiredSquareness: Float
            
            init(color: Backing.Color, squareness: Float = 1) {
                desiredColor = color.toColorData()
                desiredSquareness = squareness
            }
            
            fileprivate var currentColor: ColorData? = .none
            fileprivate var currentSquareness: Float? = .none
            
            enum CodingKeys: CodingKey {
                case desiredColor
                case desiredSquareness
            }
        }
        
        struct System: RealityKit.System {
            static let query = EntityQuery(where: .has(Component.self) && .has(ModelComponent.self))
            init(scene: Scene) { }
            
            func update(context: SceneUpdateContext) {
                context.entities(matching: Self.query, updatingSystemWhen: .rendering).forEach { entity in
                    guard var component = entity.components[Component.self],
                          (component.currentColor != component.desiredColor || component.currentSquareness != component.desiredSquareness),
                          var model = entity.components[ModelComponent.self],
                          let material = model.materials.first
                    else { return }
                    defer {
                        component.currentColor = component.desiredColor
                        component.currentSquareness = component.desiredSquareness
                        entity.components.set(component)
                        entity.components.set(model)
                    }
                    
                    // color change
                    switch material {
                    case var shaderGraph as ShaderGraphMaterial:
                        try? shaderGraph.setParameter(
                            name: "BaseColor",
                            value: .color(.init(component.desiredColor.toColor())))
                        model.materials = [shaderGraph]
                    default:
                        let new = SimpleMaterial(
                            color: .init(component.desiredColor.toColor()),
                            roughness: 0.5,
                            isMetallic: false)
                        model.materials = [new]
                    }
                    
                    // mesh change
                    let mesh = generateMesh(squareness: component.desiredSquareness)
                    try? model.mesh.replace(with: mesh.contents)
                }
            }
            
            private func generateMesh(squareness: Float) -> MeshResource {
                let sphereness = 1 - squareness
                return .generateBox(width: 1, height: 1, depth: 0.35 + sphereness * 0.65, cornerRadius: 0.35 + sphereness * 0.15)
    //            return MeshResource.generateBox(width: 1, height: 1, depth: 0.35, cornerRadius: 0.35)
            }
        }
    }
}
