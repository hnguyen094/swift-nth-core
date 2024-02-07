//
//  TextDisplay.View.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import SwiftUI
import ComposableArchitecture
import Marquee

extension TextDisplay {
    struct View: SwiftUI.View {
        let store: StoreOf<TextDisplay>
    }
}

extension TextDisplay.View {
    var body: some SwiftUI.View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView(.vertical) {
                Text(viewStore.text)
            }
            .navigationTitle(viewStore.title)
        }
    }
}

#Preview {
    NavigationView {
        TextDisplay.View(store: Store(initialState: TextDisplay.State(
            title: "Some Preview Title",
            autoscroll: true,
            text: "Some _formatted_ text in a `ScrollView`.")) {
                TextDisplay()
            })
    }
}
