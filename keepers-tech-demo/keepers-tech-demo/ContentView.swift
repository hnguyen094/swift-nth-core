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
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @Dependency(\.logger) var logger
    @Dependency(\.arkitSessionManager.worldTrackingData) var worldTracker

    var body: some View {
        ZStack {
            RealityView { content in
                let ent = Creature.Entity(store: store, windowed: true)
                ent.transform.translation = [0, 0, 0]
                content.add(ent)
            }
//            .frame(depth: 0, alignment: .back)
            .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { value in
                logger.debug("SpatialTap at \(value.location3D)")
                store.send(._nextAnimation)
            })
            VStack {
                Spacer()
                Toggle(isOn: $showImmersiveSpace) {
                    Text("Show Immersive Space")
                }
                .toggleStyle(.button)
                Button("Change Animation/Color") {
                    store.send(._nextAnimation)
                    let randomColor: SwiftUI.Color = .init(
                        hue: .random(in: 0...1),
                        saturation: .random(in: 0.5...1),
                        brightness: 1)
                    store.send(.set(\.$color, .init(randomColor)))
                }
            }
        }
        .onAppear { store.send(.onLoad) }
        
        .padding()
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
    ContentView(store: Store(initialState: Creature.Feature.State(), reducer: { Creature.Feature() } ))
}
