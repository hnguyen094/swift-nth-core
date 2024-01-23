//
//  keepers_tech_demoApp.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import ComposableArchitecture
import ARKit

@main
struct keepers_tech_demoApp: App {
    @Dependency(\.modelContext) private var modelContext
    @Dependency(\.arkitSessionManager) private var sessionManager
    
    @State private var volumeSize: Size3D = .init(width: 0.2, height: 0.3, depth: 0.05)

    private let store = Store(initialState: Feature.State(step: .heroScreen)) {
        Feature()
    }
    
    var body: some Scene {
        WindowGroup(id: RootView.ID) {
            RootView(store: store)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Creature.VolumetricView.ID) {
            IfLetStore(store.scope(state: \.creature, action: \.creature)) { creatureStore in
                Creature.VolumetricView(store: creatureStore, volumeSize: volumeSize)
                    .task {
                        await modelContext.enableAutosave()
                        await sessionManager.attemptStartARKitSession()
                    }
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(volumeSize, in: .meters)
        
        ImmersiveSpace(id: Creature.ImmersiveView.ID) {
            Creature.ImmersiveView()
                .task {
                    await modelContext.enableAutosave()
                    await sessionManager.attemptStartARKitSession()
                }
        }
    }

    init() {
        Emoting.Component.registerComponent()
        Emoting.System.registerSystem()
        Billboard.Component.registerComponent()
        Billboard.System.registerSystem()
        Follow.Component.registerComponent()
        Follow.System.registerSystem()
    }
}
