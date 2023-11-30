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
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    private var store: StoreOf<Root> {
        Store(initialState: Root.State()) {
            Root(openImmersiveSpace: openImmersiveSpace, dismissImmersiveSpace: dismissImmersiveSpace)
        }
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
