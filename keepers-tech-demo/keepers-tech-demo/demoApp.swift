//
//  demoApp.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import ComposableArchitecture
import ARKit

@main
struct demoApp: App {
    @Dependency(\.modelContext) private var modelContext
    @Dependency(\.arkitSessionManager) private var sessionManager
    @Dependency(\.logger) private var logger
    
    @State private var volumeSize: Size3D = .init(width : 0.2,
                                                  height: 0.3,
                                                  depth : 0.05)

    private let store = Store(initialState: Feature.State(step: .heroScreen)) {
        Feature()
    }
    
    var body: some Scene {
        WindowGroup(id: RootView.ID) {
            RootView(store: store)
                .onAppear { store.send(.onLoad) }
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Creature.VolumetricView.ID) {
            let creatureStore = store.scope(state: \.creature, action: \.creature)
            Creature.VolumetricView(store: creatureStore, volumeSize: volumeSize)
                .task {
                    await modelContext.enableAutosave()
                    await sessionManager.attemptStartARKitSession()
                }
                .onAppear {
                    store.send(.set(\.$isVolumeOpen, true))
                    logger.info("VolumetricView appeared")
                }
                .onDisappear {
                    store.send(.set(\.$isVolumeOpen, false))
                    logger.info("VolumetricView disappeared")
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
                .onAppear {
                    store.send(.set(\.$isImmersiveSpaceOpen, true))
                    logger.info("ImmersiveSpace appeared")
                }
                .onDisappear {
                    store.send(.set(\.$isImmersiveSpaceOpen, false))
                    logger.info("ImmersiveSpace disappeared")
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

        Demo.Component.registerComponent()
        Demo.System.registerSystem()
        Creature.Body.Component.registerComponent()
        Creature.Body.System.registerSystem()
    }
}
