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
        
        private(set) var body: ModelEntity? = .none
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
            components.set(Demo.Component())

            scale = .init(repeating: 0.1)

            addBody()
            addHighlightContainer()
        }

        private func subscribeToStore() {
            viewStore.publisher.intent.sink { [weak self] newIntent in
                guard let self = self, let body = self.body,
                      var emotingComponent = body.components[Emoting.Component.self],
                      var bodyComponent = body.components[Body.Component.self]
                else { return }
                defer {
                    body.components.set(emotingComponent)
                    body.components.set(bodyComponent)
                }
                emotingComponent.desiredAnimation = newIntent.emotionAnimation
                bodyComponent.desiredSquareness = newIntent.squareness
            }
            .store(in: &cancellables)
            viewStore.publisher.color.sink { [weak self] color in
                guard let self = self,
                      let body = self.body,
                      var bodyComponent = body.components[Body.Component.self]
                else { return }
                defer { body.components.set(bodyComponent) }
                bodyComponent.desiredColor = color.toColorData()
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
            let material: Material = customMaterialSource ?? SimpleMaterial()
            let body = ModelEntity(mesh: .generateBox(size: 1), materials: [material])
            body.components.set(Emoting.Component())
            body.components.set(Body.Component(color: viewStore.color, squareness: viewStore.intent.squareness))
            
            if !windowed { body.generateCollisionShapes(recursive: false) }
            
            let bodyOffset = RealityKit.Entity()
            bodyOffset.position = [0, 0.7, 0]
            
            bodyOffset.addChild(body)
            addChild(bodyOffset)
            self.body = body
        }
        
        private func addHighlightContainer() {
            guard let body = self.body else { return }
            
            let radius: Float = 0.7
            
            let mesh = MeshResource.generateSphere(radius: radius)
            let material = SimpleMaterial(color: .init(white: 0, alpha: 0.2), roughness: 0.5, isMetallic: false)

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
