//
//  WaitForLoad.View.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

extension WaitForLoad {
    struct View: SwiftUI.View {
        let store: StoreOf<WaitForLoad>
    }
}

extension WaitForLoad.View {
    var body: some SwiftUI.View {
        NavigationView {
            WithViewStore(self.store, observe: identity) { viewStore in
                VStack {
                    ProgressView {
                        Text(viewStore.loadingText)
                    }
                    
                    Button {
                        viewStore.send(.cancelTask)
                    } label: {
                        Text("cancel")
                    }
                }
            }
        }
    }
}

#Preview {
    WaitForLoad.View(store: Store(initialState: WaitForLoad.State(
        loadingText: "Loading cats...",
        task: nil)) {
            WaitForLoad()
        })
}
