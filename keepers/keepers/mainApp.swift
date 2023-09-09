//
//  mainApp.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct mainApp: App {
    private var store = Store(initialState: Root.State()) {
        Root()
    }

    init() {}
    
    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
