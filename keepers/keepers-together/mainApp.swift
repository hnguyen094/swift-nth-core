//
//  mainApp.swift
//  keepers:together
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct mainApp: App {
    private var store = Store(initialState: Root.State()) {
        Root()
    }
    
    var body: some Scene {
        WindowGroup {
            Root.View(store: store)
        }
        ImmersiveSpace(id: SampleImmersiveView.Id) {
            SampleImmersiveView()
        }
    }
}
