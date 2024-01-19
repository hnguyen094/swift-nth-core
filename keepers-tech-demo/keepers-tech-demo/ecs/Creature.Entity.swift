//
//  Creature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//
import RealityKit

import ComposableArchitecture
import Combine

enum Creature {
    class Entity: RealityKit.Entity {
        @Dependency(\.logger) private var logger
        
        private let viewStore: ViewStoreOf<Feature>
        private var cancellables: Set<AnyCancellable> = []
        
        private var body: ModelEntity? = .none
        private var customMaterialSource: ShaderGraphMaterial? = .none
        private var windowed: Bool = true
        
        @MainActor init(store: StoreOf<Feature>, material: ShaderGraphMaterial?, windowed: Bool) {
            self.viewStore = ViewStore(store, observe: { $0 })
            self.customMaterialSource = material
            self.windowed = windowed
            super.init()
            initialConfiguration()
            subscribeToStore()
        }

        private func initialConfiguration() {
//            components.set(Billboard.Component(mode: .lazy(0.25)))
//            components.set(Billboard.Component(mode: .direct))
            components.set(InputTargetComponent(allowedInputTypes: .all))

            scale = .init(repeating: 0.1)

            addBody()
            addHighlightContainer()
        }

        private func subscribeToStore() {
            viewStore.publisher.emotionAnimation.sink { [weak self] newValue in
                guard let self = self, let body = self.body else { return }
                var component = body.components[Emoting.Component.self]!
                component.desiredAnimation = newValue
                body.components.set(component)
            }
            .store(in: &cancellables)
            viewStore.publisher.color.sink { [weak self] color in
                guard let self = self,
                      let body = self.body,
                      let material = body.model!.materials.first
                else { return }
                switch material {
                case is SimpleMaterial:
                    let new = SimpleMaterial(color: .init(color), roughness: 0.5, isMetallic: false)
                    body.model!.materials = [new]
                case var shaderGraph as ShaderGraphMaterial:
                    try? shaderGraph.setParameter(name: "BaseColor", value: .color(.init(color)))
                    body.model!.materials = [shaderGraph]
                default:
                    logger.fault("Unexpected shader type. Falling back to SimpleMaterial")
                    let new = SimpleMaterial(color: .init(color), roughness: 0.5, isMetallic: false)
                    body.model!.materials = [new]
                }
            }
            .store(in: &cancellables)
            viewStore.publisher._useCustomMaterial.sink { [weak self]  useCustomMaterial in
                guard let self = self, 
                      let body = self.body,
                      let customMaterial = customMaterialSource
                else { return }

                if useCustomMaterial {
                    var new = customMaterial
                    try? new.setParameter(name: "BaseColor", value: .color(.init(viewStore.color)))
                    body.model!.materials = [new]
                } else {
                    let new = SimpleMaterial(color: .init(viewStore.color), roughness: 0.5, isMetallic: false)
                    body.model!.materials = [new]
                }
            }
            .store(in: &cancellables)
        }
        
        private func addBody() {
            if case .none = self.customMaterialSource {
                logger.fault("Custom material missing when initializing Creature.")
            }
//            let mesh = MeshResource.generateSphere(radius: 0.5)
            let mesh = MeshResource.generateBox(width: 1, height: 1, depth: 0.35, cornerRadius: 0.35)
//            let mesh = MeshResource.generateBox(size: [1, 1, 0.35], majorCornerRadius: 0.5, minorCornerRadius: 0.1)
            
            let material: Material = customMaterialSource ?? SimpleMaterial(color: .init(viewStore.color), roughness: 0.5, isMetallic: false)
//            let customMaterial = Shader

            let body = ModelEntity(mesh: mesh, materials: [material])
            body.components.set(Emoting.Component())
            
            if !windowed { body.generateCollisionShapes(recursive: false) }
            
            let bodyOffset = RealityKit.Entity()
            bodyOffset.position = [0, 0.65, 0]
            
            bodyOffset.addChild(body)
            addChild(bodyOffset)
            self.body = body
        }
        
        private func addHighlightContainer() {
            guard let body = self.body else { return }
            
            let radius: Float = 0.75
            
            let mesh = MeshResource.generateSphere(radius: radius)
            let material = SimpleMaterial(color: .clear, roughness: 0.5, isMetallic: false)

            let model = ModelEntity(mesh: mesh, materials: [material])
            model.scale = .init(repeating: -1)
            
            let container = RealityKit.Entity()
            container.components.set(HoverEffectComponent())
            container.components.set(CollisionComponent(shapes: [.generateSphere(radius: radius)]))
            container.components.set(Follow.Component(followeeID: body.id))
            
            container.addChild(model)
            
            addChild(container)
        }
        
        @MainActor required init() {
            viewStore = ViewStore(Store(initialState: Feature.State()) { Feature() }, observe: { $0 })
            super.init()
            initialConfiguration()
        }
    }
}
