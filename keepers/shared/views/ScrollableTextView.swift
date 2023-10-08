//
//  ScrollableTextView.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import SwiftUI
import ComposableArchitecture
import Marquee

struct ScrollableTextView: View {
    let store: StoreOf<TextDisplay>
        
    var body: some View {
        NavigationView {
            WithViewStore(self.store, observe: identity) { viewStore in
                ScrollView(.vertical) {
                    Text(viewStore.text)
                }
                .navigationTitle(viewStore.title)
            }
        }
    }
}

#Preview {
    ScrollableTextView(store: Store(initialState: TextDisplay.State(
        title: "Some Preview Title",
        autoscroll: true,
        text: "Some _formatted_ text in a `ScrollView`.")) {
            TextDisplay()
        })
}
