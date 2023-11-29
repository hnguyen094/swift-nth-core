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
                    store: store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /Destination.State.settings,
                    action: Destination.Action.settings) { store in
                        NavigationView {
                            AudioSettings.View.init(store: store)
                        }
                    }
                .navigationDestination(
                    store: store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /Destination.State.attribution,
                    action: Destination.Action.attribution,
                    destination: TextDisplay.View.init(store:))
                .navigationTitle("Keepers")
            }
        }
    }
}
