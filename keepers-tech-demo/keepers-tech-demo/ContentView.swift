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

    var body: some View {
        ZStack {
//            Toggle(isOn: $showImmersiveSpace) {
//                Text("Show Immersive Space")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//                .toggleStyle(.button)

            RealityView { content in
                let ent = Creature.Entity(store: store, windowed: true)
                ent.transform.translation = [0, 0, 0]
                content.add(ent)
            }
//            .frame(depth: 0, alignment: .back)
//            .gesture(TapGesture().targetedToAnyEntity()
//                .onEnded { _ in
//                    store.send(._nextAnimation)
//                })
            VStack {
                Spacer()
                Button("Change Animation") {
                    store.send(._nextAnimation)
                }
            }
        }
        
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
