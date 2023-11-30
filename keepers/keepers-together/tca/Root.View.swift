//
//  Root.View.swift
//  keepers-together
//
//  Created by Hung on 11/23/23.
//

import SwiftUI
import ComposableArchitecture

extension Root {
    struct View: SwiftUI.View {
        let store: StoreOf<Root>
        
        var body: some SwiftUI.View {
            NavigationStack {
                Button("Immerse") {
                    store.send(.startButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Debug World Tracker") {
                    store.send(.debugButtonTapped)
                }
                .buttonStyle(.bordered)
                Button("Settings") {
                    store.send(.settingsButtonTapped)
                }
                .buttonStyle(.bordered)
                Button("Attributions") {
                    store.send(.attributionButtonTapped)
                }
                .frame(width: nil, height: nil, alignment: .bottomTrailing)
                
                .sheet(
                    store: store.scope(
                        state: \.$destination.settings,
                        action: \.destination.settings))
                { store in
                    NavigationView {
                        AudioSettings.View(store: store)
                    }
                }
                .navigationDestination(
                    store: store.scope(
                        state: \.$destination.attribution,
                        action: \.destination.attribution),
                    destination: TextDisplay.View.init(store:))
                .navigationTitle("Keepers")
            }
        }
    }
}

#Preview {
    Root.View(store: Store(initialState: Root.State()) {
        Root()
    })
}
