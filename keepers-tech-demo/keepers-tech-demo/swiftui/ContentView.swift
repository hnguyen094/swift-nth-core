//
//  ContentView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ComposableArchitecture


struct ContentView: View {
    let store: StoreOf<Creature.Feature>
    
    @State var volumeSize: Size3D
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var shouldUseCustomMaterial = true

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.physicalMetrics) var metrics
    
    @Dependency(\.logger) var logger
    @Dependency(\.arkitSessionManager.worldTrackingData) var worldTracker
    @Dependency(\.audioSession) var audioSession

    var tap: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { event in
                store.send(._nextAnimation)
            }
    }
    
    var body: some View {
        ZStack {
            VStack {
                Toggle(isOn: $showImmersiveSpace) {
                    Text("Show Immersive Space")
                }
                .toggleStyle(.button)
                .glassBackgroundEffect()
                Button("Change Color") {
                    let randomColor: SwiftUI.Color = .init(
                        hue: .random(in: 0...1),
                        saturation: 1,
                        brightness: 1)
                    store.send(.set(\.$color, .init(randomColor)))
                }
                .glassBackgroundEffect()

                Toggle(isOn: $shouldUseCustomMaterial) {
                    Text("Use Custom Material")
                }
                .toggleStyle(.button)
                .glassBackgroundEffect()
                Spacer()
            }
            RealityView { content, attachments in
                let creatureMaterial = try? await ShaderGraphMaterial(
                    named: "/Root/CelShading",
                    from: "Materials/CustomMaterials",
                    in: realityKitContentBundle)
                let ent = Creature.Entity(store: store, material: creatureMaterial, windowed: true)
                ent.transform.translation = [0, -Float(volumeSize.height / 2), 0] // grounding
                content.add(ent)
                
                if let buttonAttachment = attachments.entity(for: "Button") {
                    ent.addChild(buttonAttachment)
                    buttonAttachment.transform.translation = [0, 0, 1]
                }
            } attachments: {
                Attachment(id: "Button") {
                    Toggle(isOn: $showImmersiveSpace) {
                        Text("Show Immersive Space")
                    }
                    .toggleStyle(.button)
                    .glassBackgroundEffect()
                }
            }
//            .frame(depth: 100)
            .gesture(tap)
        }
        .onAppear { store.send(.onLoad) }
        .onChange(of: shouldUseCustomMaterial) { _, newValue in
            store.send(.set (\.$_useCustomMaterial, newValue))
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: ImmersiveView.ID) {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(
        store: Store(initialState: Creature.Feature.State(), reducer: { Creature.Feature() }),
        volumeSize: .init(width: 1, height: 1, depth: 0.25)
    )
}
