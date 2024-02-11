//
//  dimensionsApp.swift
//  dimensions
//
//  Created by hung on 2/6/24.
//

import SwiftUI
import ComposableArchitecture
import NthComposable

@main
struct dimensionsApp: App {
    let store = Store(initialState: Feature.State()) {
        Feature()
    }

    var body: some Scene {
        let lifecycle = store.scope(state: \.sceneLifecycle, action: \.sceneLifecycle)
        
        WindowGroup(id: ContentView.ID) {
            ContentView(store: store)
                .registerLifecycle(lifecycle, as: .window(.id(ContentView.ID)))
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: ImmersiveView.ID) {
            ImmersiveView(store: store)
                .registerLifecycle(lifecycle, as: .immersive(ImmersiveView.ID))
        }
    }

    init() {
        TextSpin.register()
        store.send(.onLaunch)
    }
}
