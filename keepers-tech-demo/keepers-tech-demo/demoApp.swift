//
//  demoApp.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import ComposableArchitecture

import NthCore
import NthComposable

@main
struct demoApp: App {
    @State private var volumeSize: Size3D = .init(width : 0.2, height: 0.3, depth : 0.05)

    let bootstrap = Store(initialState: .bootstrapping) {
        Bootstrapping(bootstrap: Feature.bootstrap, initialState: .init(step: .heroScreen)) {
            Feature()
        }
    }
    
    var body: some Scene {
        WindowGroup(id: FlatView.ID) {
            BootstrapView(store: bootstrap) { store in
                FlatView(store: store)
                    .onAppear { store.send(.onLoad) }
            } placeholder: {
                ProgressView()
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Creature.VolumetricView.ID) {
            BootstrapView(store: bootstrap) { store in
                let creatureStore = store.scope(state: \.creature, action: \.creature)
                Creature.VolumetricView(store: creatureStore, volumeSize: volumeSize)
                    .onAppear { store.send(.set(\.isVolumeOpen, true)) }
                    .onDisappear { store.send(.set(\.isVolumeOpen, false)) }
            } placeholder: {
                ProgressView()
            }
        }
        .windowStyle(.volumetric)
        .defaultSize(volumeSize, in: .meters)
        
        ImmersiveSpace(id: Creature.ImmersiveView.ID) {
            BootstrapView(store: bootstrap) { store in
                let creatureStore = store.scope(state: \.creature, action: \.creature)
                Creature.ImmersiveView(store: creatureStore)
                    .onAppear { store.send(.set(\.isImmersiveSpaceOpen, true)) }
                    .onDisappear { store.send(.set(\.isImmersiveSpaceOpen, false)) }
            } placeholder: {
                ProgressView()
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
