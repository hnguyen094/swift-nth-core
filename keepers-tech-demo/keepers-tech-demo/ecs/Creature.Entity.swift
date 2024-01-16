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
        private let viewStore: ViewStoreOf<Feature>
        private var cancellables: Set<AnyCancellable> = []
        
        private var body: RealityKit.Entity? = .none
        
        @MainActor init(store: StoreOf<Feature>, windowed: Bool) {
            self.viewStore = ViewStore(store, observe: { $0 })
            super.init()
            initialConfiguration(windowed: windowed)
            subscribeToStore()
        }

        private func initialConfiguration(windowed: Bool) {
//            components.set(Billboard.Component(mode: .lazy(0.25)))
//            components.set(Billboard.Component(mode: .direct))
            scale = [0.2, 0.2, 0.2]
            
            addBody(windowed: windowed)
        }

        private func addBody(windowed: Bool) {
            let mesh = MeshResource.generateBox(width: 1, height: 1, depth: 0.35, cornerRadius: 0.5)
//            let mesh = MeshResource.generateBox(size: [1, 1, 0.35], majorCornerRadius: 0.5, minorCornerRadius: 0.1)
            let material = SimpleMaterial(color: .cyan, roughness: 0.5, isMetallic: true)

            let body = ModelEntity(mesh: mesh, materials: [material])
            body.name = "creature_body"
            body.components.set(Emoting.Component())
            self.body = body
            
            if !windowed {
                body.generateCollisionShapes(recursive: true)
                // TODO: add movement components too, etc.
            }
            
            addChild(body)
        }
        
        private func subscribeToStore() {
            viewStore.publisher.emotionAnimation.sink { [weak self] newValue in
                guard let self = self else { return }
                var component = body!.components[Emoting.Component.self]!
                component.desiredAnimation = newValue
                body!.components.set(component)
            }
            .store(in: &cancellables)
        }
        
        @MainActor required init() {
            viewStore = ViewStore(Store(initialState: Feature.State()) { Feature() }, observe: { $0 })
            super.init()
            initialConfiguration(windowed: true)
        }
    }
}
