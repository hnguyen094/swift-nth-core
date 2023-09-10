//
//  RootView.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    @Dependency(\.dataContainer) var dataContainer
    typealias Destination = Root.Destination
    let store: StoreOf<Root>
        
    var body: some View {
        Button("Start") {}
            .buttonStyle(RedCircleButtonStyle())
        Button("Settings") {
            store.send(Root.Action.settingsButtonTapped)
        }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Destination.State.settings,
                action: Destination.Action.settings
            ) { store in
                AudioSettingsView(store: store)
            }
    }
}
                   
#Preview {
    RootView(store: Store(initialState: Root.State()) {
        Root()
    })
}
