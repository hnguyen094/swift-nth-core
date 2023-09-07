//
//  ErrorView.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI

/// A view to display an error to the user.
///
/// Partially complete, and based off of [this tutorial](https://developer.apple.com/tutorials/app-dev-training/handling-errors).
/// Particularly, we need to actually test this view with simulated errors, such as data model corruption.
struct ErrorView: View {
    let error: Error
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("An error has occurred!")
                    .font(.title)
                    .padding(.bottom)
                Text("Encountered error \(error.localizedDescription)")
                    .font(.headline)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    struct SampleError : Error { }
}

#Preview {
    ErrorView(error: ErrorView.SampleError())
}
