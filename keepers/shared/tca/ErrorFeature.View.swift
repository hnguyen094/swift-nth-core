//
//  ErrorFeature.View.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI
import ComposableArchitecture

extension ErrorFeature {
    /// A view to display an error to the user.
    ///
    /// Partially complete, and based off of [this tutorial](https://developer.apple.com/tutorials/app-dev-training/handling-errors ).
    /// Particularly, we need to actually test this view with simulated errors, such as data model corruption.
    struct View: SwiftUI.View {
        let store: StoreOf<ErrorFeature>
    }
}

extension ErrorFeature.View {
    var body: some View {
        WithViewStore(self.store, observe: identity) { viewStore in
            Text(viewStore.error.localizedDescription)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Dismiss") {
                            store.send(.dismiss)
                        }
                    }
                }
                .navigationTitle("Error Occurred")
        }
    }
}


#Preview {
    NavigationView {
        ErrorFeature.View(store: Store(initialState: ErrorFeature.State(
            error: ErrorFeature.SampleError())) {
                ErrorFeature()
            })
    }
}
