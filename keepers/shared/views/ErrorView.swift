//
//  ErrorView.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI

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
