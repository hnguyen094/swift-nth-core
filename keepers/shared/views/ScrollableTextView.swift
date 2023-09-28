//
//  ScrollableTextView.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import SwiftUI
import ComposableArchitecture

struct ScrollableTextView: View {
    let store: StoreOf<TextDisplay>
        
    var body: some View {
        ScrollView(.vertical) {
            WithViewStore(self.store, observe: identity) { viewStore in
                Text("\(viewStore.text)")
            }
        }
        .navigationTitle("Attributions")
    }
}
