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

    var shouldDisable: Bool {
        guard case .some(_) = store.sceneLifecycle.openedImmersiveSpace
        else { return false }
        if case .meshes = store.mode {
            return true
        }
        return false
    }

    var animationState: Bool {
        if case .meshes = store.mode {
            return true
        }
        return false
    }

    var body: some View {
        NavigationStack {
            HStack {
                Spacer()
                Text("Measure using")
                let usesMetricSystem: Binding<Bool> = $store.usesMetricSystem
                let isPlanes = Binding<Bool> {
                    if case .planes = store.mode { return true }
                    return false
                } set: { store.send(.toggleMode(newValue: $0)) }
                Toggle(usesMetricSystem.wrappedValue ? "the metric system" : "the imperial system", isOn: usesMetricSystem)
                    .toggleStyle(.button)
                Toggle(isPlanes.wrappedValue ? "automatically" : "manually", isOn: isPlanes)
                    .toggleStyle(.button)
                    .help(isPlanes.wrappedValue ? "shows all detected plane dimensions" : "shows distances between two points")
                Spacer()
            }
            switch store.mode {
            case .meshes:
                Text("""
                    Look and tap on surfaces to place points.
                    To start over, exit and reopen the immersive environment.
                    """)
                .multilineTextAlignment(.center)
                .padding()
            case .planes:
                EmptyView()
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
            if shouldDisable {
                Text("Press the crown to reenable the UI.")
                    .font(.footnote)
            }
        }
        .frame(width: 500, height: 400)
        .disabled(shouldDisable)
        .animation(.default, value: animationState)
    }
}

#Preview(windowStyle: .automatic) {
    ContentView(store: .init(initialState: .init(), reducer: {
        dimensionsApp.Feature()
    }))
}
