//
//  ContentView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        ZStack {
            Toggle(isOn: $showImmersiveSpace) {
                Text("Show Immersive Space")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
                .toggleStyle(.button)

            RealityView { content in
                let ent = Creature.Entity()
                content.add(ent)
            }
            .frame(depth: 0, alignment: .front)
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
    ContentView()
}
