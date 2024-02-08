//
//  ContentView.swift
//  dimensions
//
//  Created by hung on 2/6/24.
//

import SwiftUI
import RealityKit
import ComposableArchitecture
import NthComposable

struct ContentView: View {
    @Bindable var store: StoreOf<dimensionsApp.Feature>

    var body: some View {
        VStack {
            Text("Hello, world!")
            SceneToggle(
                "Show Immersive Space",
                scene: .immersive(ImmersiveView.ID),
                using: store.scope(state: \.sceneLifecycle, action: \.sceneLifecycle)
            )
            .toggleStyle(.button)
            .padding(.top, 50)
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(store: .init(initialState: .init(), reducer: {
        dimensionsApp.Feature()
    }))
}
