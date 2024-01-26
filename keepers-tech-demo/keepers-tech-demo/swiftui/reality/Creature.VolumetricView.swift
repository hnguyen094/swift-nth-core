//
//  Creature.VolumetricView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ComposableArchitecture

extension Creature {
    struct VolumetricView: SwiftUI.View {
        let store: StoreOf<Creature.Feature>
        
        @State var volumeSize: Size3D
        @State private var shouldUseCustomMaterial = true
        @State private var shouldShowTextBubble = false
        @State private var squareness: Float = 1
        
        @Environment(\.physicalMetrics) var metrics
        
        var body: some SwiftUI.View {
            ZStack {
//                debugButtons
                Creature.View(store: store, volumeSize: volumeSize)
            }
            .onChange(of: shouldUseCustomMaterial) { _, use in
                store.send(.set (\.$_useCustomMaterial, use))
            }
            .onChange(of: shouldShowTextBubble) { _, show in
                store.send(._toggleTextBubble(show))
            }
            .onChange(of: squareness) {_, squareness in
                store.send(._changeSquareness(squareness))
            }
        }

        var debugButtons: some SwiftUI.View {
            VStack {
                Button("Change Color") {
                    let randomColor: SwiftUI.Color = .init(
                        hue: .random(in: 0...1),
                        saturation: 1,
                        brightness: 1)
                    store.send(.set(\.$color, .init(randomColor)))
                }
                .glassBackgroundEffect()
                
                Toggle(isOn: $shouldShowTextBubble) {
                    Text("Toggle bubble")
                }
                .toggleStyle(.button)
                .glassBackgroundEffect()
                
                Toggle(isOn: $shouldUseCustomMaterial) {
                    Text("Use Custom Material")
                }
                .toggleStyle(.button)
                .glassBackgroundEffect()
                Slider(value: $squareness) {
                    Text("Squareness")
                }
                Spacer()
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    Creature.VolumetricView(
        store: Store(initialState: Creature.Feature.State(), reducer: { Creature.Feature() }),
        volumeSize: .init(width: 1, height: 1, depth: 0.25)
    )
}
