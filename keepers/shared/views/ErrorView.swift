//
//  ErrorView.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI
import ComposableArchitecture

/// A view to display an error to the user.
///
/// Partially complete, and based off of [this tutorial](https://developer.apple.com/tutorials/app-dev-training/handling-errors ).
/// Particularly, we need to actually test this view with simulated errors, such as data model corruption.
struct ErrorView: View {
    let store: StoreOf<ErrorFeature>

    var body: some View {
        NavigationView {
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
}

#Preview {
    ErrorView(store: Store(initialState: ErrorFeature.State(
        error: ErrorFeature.SampleError())) {
            ErrorFeature()
        })
}
