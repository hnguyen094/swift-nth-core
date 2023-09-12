//
//  RootView.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    typealias Destination = Root.Destination
    let store: StoreOf<Root>
        
    var body: some View {
        NavigationStack {
                Button("Pets") {
                    store.send(Root.Action.startButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            
                Button("Settings") {
                    store.send(Root.Action.settingsButtonTapped)
                }
                .buttonStyle(.bordered)
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Destination.State.settings,
                action: Destination.Action.settings
            ) { store in
                AudioSettingsView(store: store)
            }
            .navigationTitle("Keepers")
            .navigationDestination(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Destination.State.petsList,
                action: Destination.Action.petsList
            ) { store in
                PetsView(store: store)
            }
        }
    }
}
                   
#Preview {
    RootView(store: Store(initialState: Root.State()) {
        Root()
    })
}
