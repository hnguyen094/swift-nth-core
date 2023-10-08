//
//  WaitForLoadView.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//

import SwiftUI
import ComposableArchitecture

struct WaitForLoadView: View {
    let store: StoreOf<WaitForLoad>
        
    var body: some View {
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
    WaitForLoadView(store: Store(initialState: WaitForLoad.State(
        loadingText: "Loading cats...",
        task: nil)) {
            WaitForLoad()
        })
}
