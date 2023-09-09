//
//  RootView.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<Root>
    
    @Dependency(\.audioPlayer) var audioPlayer
    
    var body: some View {
        
        Button("Settings") {
            store.send(Root.Action.settingsButtonTapped)
        }
            .sheet(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Root.Destination.State.settings,
                action: Root.Destination.Action.settings
            ) { store in
                AudioSettingsView(store: store)
            }
    }
}

struct AudioSettingsView: View {
    let store: StoreOf<AudioSettings>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Slider(
                value: viewStore.binding(
                    get: \.volumes[AudioPlayerClient.AudioCategory.main]!,
                    send: { .requestVolumeUpdate($0, AudioPlayerClient.AudioCategory.main) }),
                in: 0...1,
                step: 0.05
            ) {
                Text("Main volume")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            }
        }
    }
}


                   
#Preview {
    RootView(store: Store(initialState: Root.State()) {
        Root()
    })
}
