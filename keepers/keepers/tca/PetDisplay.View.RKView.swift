//
//  PetDisplay.View.RKView.swift
//  keepers
//
//  Created by Hung on 9/22/23.
//

import SwiftUI
import RealityKit
import ComposableArchitecture

extension PetDisplay.View {
    struct RKView: UIViewRepresentable {
        let viewStore: ViewStoreOf<PetDisplay>
        @Binding var skyboxName: String
        @Binding var energy: Int8
        
        init(viewStore store: ViewStoreOf<PetDisplay>) {
            viewStore = store
            _skyboxName = viewStore.binding(
                get: { $0.skyboxName },
                send: { .changeSkybox($0) })
            _energy = viewStore.binding(
                get: { $0.pet.personality.energy },
                send: .noop )
        }
        
        func makeUIView(context: Context) -> ARView {
            let arView = ARView(
                frame: .zero,
                cameraMode: .nonAR,
                automaticallyConfigureSession: false)
            
            loadSkybox(arView)
            
            let anchor = AnchorEntity()
            let petEntity = createPetEntity(viewStore.pet)
            anchor.addChild(petEntity)
            
            arView.installGestures(.all, for: petEntity)
            
            arView.scene.addAnchor(anchor)
            return arView
        }
        
        func updateUIView(_ arView: UIViewType, context: Context) {
            // loadSkybox(arView)
        }
        
        private func createPetEntity(_ pet: PetIdentity) -> ModelEntity {
            let mesh : MeshResource = .generateSphere(radius: 0.25)
            let petEntity = ModelEntity(mesh: mesh)
            petEntity.components[PetComponent.self] = PetComponent()
            petEntity.components[AppComponent.Bounce.self] = AppComponent.Bounce(
                amplitude: (Float(energy) + Float(Int8.max)) / 200.0,
                elapsedTime: 0)
            
            petEntity.generateCollisionShapes(recursive: true)
            
            return petEntity
        }
        
        private func loadSkybox(_ arView: ARView) {
            do {
                let skyboxResource = try EnvironmentResource
                    .load(named: skyboxName)
                arView.environment.background = .skybox(skyboxResource)
                arView.environment.lighting.resource = skyboxResource
            } catch {
                viewStore.send(.skyboxError(error))
            }
        }
        
        struct PetComponent: Component {}
    }
}
