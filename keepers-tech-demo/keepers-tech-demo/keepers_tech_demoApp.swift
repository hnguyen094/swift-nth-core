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
    @Dependency(\.arkitSessionManager) private var sessionManager

    private let store = Store(initialState: Creature.Feature.State()) {
        Creature.Feature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .task {
                    await sessionManager.attemptStartARKitSession()
                }
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.25, height: 0.25, depth: 0.05, in: .meters)

        ImmersiveSpace(id: ImmersiveView.ID) {
            ImmersiveView()
                .task {
                    await sessionManager.attemptStartARKitSession()
                }
        }
    }

    init() {
        Emoting.Component.registerComponent()
        Emoting.System.registerSystem()
        Billboard.Component.registerComponent()
        Billboard.System.registerSystem()
    }
}
