//
//  AudioSettings.View.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

extension AudioSettings {
    struct View: SwiftUI.View {
        let store: StoreOf<AudioSettings>
    }
}

extension AudioSettings.View {
    typealias Category = AudioPlayerClient.AudioCategory
    
    var body: some SwiftUI.View {
        WithViewStore(self.store, observe: identity) { viewStore in
            List {
                ForEach(Category.allCases, id: \.self) {
                    createVolumeSlider(store: viewStore, category: $0)
                }
            }
            .navigationTitle("Audio Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func createVolumeSlider(
        store viewStore: ViewStoreOf<AudioSettings>,
        category: Category
    ) -> some SwiftUI.View {
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
    NavigationView {
        AudioSettings.View(store: Store(initialState: AudioSettings.State()) {
            AudioSettings()
        })
    }
}
