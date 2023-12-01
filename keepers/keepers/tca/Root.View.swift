//
//  Root.View.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

extension Root {
    struct View: SwiftUI.View {
        let store: StoreOf<Root>

        var body: some SwiftUI.View {
            NavigationStack {
                Button("Pets") {
                    store.send(Root.Action.startButtonTapped)
                }
                .buttonStyle(.borderedProminent)
                
                Button("Settings") {
                    store.send(Root.Action.settingsButtonTapped)
                }
                .buttonStyle(.bordered)
                Button("Attributions") {
                    store.send(Root.Action.attributionButtonTapped)
                }
                .frame(width: nil, height: nil, alignment: .bottomTrailing)
                
                .sheet(
                    store: store.scope(
                        state: \.$destination.settings,
                        action: \.destination.settings))
                { store in
                    NavigationView {
                        AudioSettings.View.init(store: store)
                    }
                }
                .navigationDestination(
                    store: store.scope(
                        state: \.$destination.attribution,
                        action: \.destination.attribution),
                    destination: TextDisplay.View.init(store:))
                .navigationDestination(
                    store: store.scope(
                        state: \.$destination.petsList,
                        action: \.destination.petsList),
                    destination: PetsList.View.init(store:))
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