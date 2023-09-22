//
//  PetDisplayView.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import SwiftUI
import RealityKit
import ARKit
import ComposableArchitecture

struct PetDisplayView: View {
    let store: StoreOf<PetDisplay>
    
    var body: some View {
        WithViewStore(store, observe: identity) { viewStore in
            ZStack {
                RKView(viewStore: viewStore)
                createOverlay(viewStore)
            }
        }
    }
    
    @ViewBuilder
    private func createOverlay(_ viewStore: ViewStoreOf<PetDisplay>) -> some View {
        VStack {
            Text("""
                \(viewStore.pet.name) \
                (\(viewStore.pet.birthDate.elapsedTimeDescription) old)
                """)
            Spacer()
            Button {
                // TODO: imagine this pets really hard
            } label: {
                Text("Pet so hard.")
            }
            .buttonStyle(.borderedProminent)
        }
        .font(.title2)
    }
    
    struct RKView: UIViewRepresentable {
        let viewStore: ViewStoreOf<PetDisplay>
        @Binding var skyboxName: String
        
        init(viewStore store: ViewStoreOf<PetDisplay>) {
            viewStore = store
            _skyboxName = viewStore.binding(
                get: { $0.skyboxName },
                send: { .changeSkybox($0) })
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
            petEntity.transform.translation = [0, 0, 1]
            
            
            
            arView.scene.addAnchor(anchor)
            return arView
        }
        
        func updateUIView(_ arView: UIViewType, context: Context) {
            // loadSkybox(arView)
        }
        
        private func createPetEntity(_ pet: PetIdentity) -> Entity {
            let mesh : MeshResource = .generateSphere(radius: 0.25)
            let petEntity = ModelEntity(mesh: mesh)
            petEntity.components[PetComponent.self] = PetComponent()
            
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


#Preview {
    PetDisplayView(store: Store(initialState: PetDisplay.State(
        pet: PetIdentity(name: "Test", personality: .init(), birthDate: Date()),
        skyboxName: "missing"
    )) {
        PetDisplay()
    })
}
