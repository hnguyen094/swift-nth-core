//
//  AudioSettingsView.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

struct AudioSettingsView: View {
    typealias Category = AudioPlayerClient.AudioCategory
    let store: StoreOf<AudioSettings>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store, observe: identity) { viewStore in
                List {
                    ForEach(Category.allCases, id: \.self) {
                        createVolumeSlider(store: viewStore, category: $0)
                    }
                }
                .navigationTitle("Audio Settings")
            }
        }
    }
    
    private func createVolumeSlider(
        store viewStore: ViewStoreOf<AudioSettings>,
        category: Category
    ) -> some View {
        return VStack {
            Text("\(String(describing: category))")
                .font(.headline)
            Slider(
                value: viewStore.binding(
                    get: \.volumes[category]!,
                    send: { .changeVolumeUpdateValue($0, category) }),
                in: 0...1
            ) {
                Text("Volume (\(String(describing: category)))")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: { _ in
                viewStore.send(.requestVolumeChange(category))
            }
        }
    }
}

#Preview {
    AudioSettingsView(store: Store(initialState: AudioSettings.State()) {
        AudioSettings()
    })
}
