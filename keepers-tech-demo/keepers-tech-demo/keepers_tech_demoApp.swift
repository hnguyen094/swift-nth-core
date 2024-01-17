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
    
    @State private var volumeSize: Size3D = .init(width: 0.2, height: 0.2, depth: 0.05)

    private let store = Store(initialState: Creature.Feature.State()) {
        Creature.Feature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store, volumeSize: volumeSize)
                .task {
                    await modelContext.enableAutosave()
                    await sessionManager.attemptStartARKitSession()
                }
        }
        .windowStyle(.volumetric)
        .defaultSize(volumeSize, in: .meters)

        ImmersiveSpace(id: ImmersiveView.ID) {
            ImmersiveView()
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
