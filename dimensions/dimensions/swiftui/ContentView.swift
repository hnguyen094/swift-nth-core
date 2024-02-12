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
        NavigationStack {
            HStack {
                Spacer()
                Text("Measure using")
                let binding: Binding<Bool> = $store.usesMetricSystem
                Toggle(binding.wrappedValue ? "the metric system" : "the imperial system", isOn: $store.usesMetricSystem)
                    .toggleStyle(.button)
                Spacer()
            }
            SceneToggle(
                "Stop measuring",
                "Begin measuring",
                toggling: .immersive(ImmersiveView.ID),
                using: store.scope(state: \.sceneLifecycle, action: \.sceneLifecycle)
            )
            .toggleStyle(.button)
            .padding(.top, 50)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "ruler")
                        Text("Dimensions")
                            .font(.title)
                    }
                }
            }
        }
        .frame(width: 500, height: 300)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(store: .init(initialState: .init(), reducer: {
        dimensionsApp.Feature()
    }))
}
