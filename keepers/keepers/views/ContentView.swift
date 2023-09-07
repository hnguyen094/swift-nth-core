//
//  ContentView.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI

/// The entry point for all views for this app.
struct ContentView: View {
    @State var loaded : Bool = false
    var body: some View {
        if (!loaded) {
            WaitForCloudKitDataView(active: $loaded)
        } else {
            PetListView()
        }
    }
}

#Preview {
    ContentView()
}
