//
//  demoApp.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import NthCore
import NthComposable

import SwiftUI
import ComposableArchitecture
import ARKit

@main
struct demoApp: App {
    @Dependency(\.arkitSessionManager) private var sessionManager
    @Dependency(\.logger) private var logger
    
    @State private var volumeSize: Size3D = .init(width : 0.2,
                                                  height: 0.3,
                                                  depth : 0.05)

    let bootstrap = Store(initialState: Bootstrap.State.bootstrapping) {
        Bootstrap()
    }
    
    var body: some Scene {
        WindowGroup(id: RootView.ID) {
            switch bootstrap.state {
            case .bootstrapping:
                Text("Initializing")
            case .bootstrapped:
                if let store = bootstrap.scope(state: \.bootstrapped, action: \.bootstrapped) {
                    RootView(store: store)
                        .onAppear { store.send(.onLoad) }
                }
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Creature.VolumetricView.ID) {
            SwitchStore(bootstrap) { state in
                switch state {
                case .bootstrapping:
                    Text("Initializing")
                case .bootstrapped:
                    CaseLet(/Bootstrap.State.bootstrapped, action: Bootstrap.Action.bootstrapped) { store in
                        let creatureStore = store.scope(state: \.creature, action: \.creature)
                        Creature.VolumetricView(store: creatureStore, volumeSize: volumeSize)
                            .onAppear {
                                store.send(.set(\.isVolumeOpen, true))
                                logger.info("VolumetricView appeared")
                            }
                            .onDisappear {
                                store.send(.set(\.isVolumeOpen, false))
                                logger.info("VolumetricView disappeared")
                            }
                    }
                }
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(volumeSize, in: .meters)
        
        ImmersiveSpace(id: Creature.ImmersiveView.ID) {
            SwitchStore(bootstrap) { state in
                switch state {
                case .bootstrapping:
                    Text("Initializing")
                case .bootstrapped:
                    CaseLet(/Bootstrap.State.bootstrapped, action: Bootstrap.Action.bootstrapped) { store in
                        let creatureStore = store.scope(state: \.creature, action: \.creature)
                        Creature.ImmersiveView(store: creatureStore)
                            .onAppear {
                                store.send(.set(\.isImmersiveSpaceOpen, true))
                                logger.info("ImmersiveSpace appeared")
                            }
                            .onDisappear {
                                store.send(.set(\.isImmersiveSpaceOpen, false))
                                logger.info("ImmersiveSpace disappeared")
                            }
                    }
                }
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
        
        bootstrap.send(.onLaunch)
    }
}
