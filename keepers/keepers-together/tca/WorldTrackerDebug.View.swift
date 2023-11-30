//
//  WorldTrackerDebug.View.swift
//  keepers-together
//
//  Created by Hung on 11/30/23.
//

import SwiftUI
import ComposableArchitecture

extension WorldTrackerDebug {
    struct View: SwiftUI.View {
        let store: StoreOf<WorldTrackerDebug>
    }
}

extension WorldTrackerDebug.View {
    var body: some SwiftUI.View {
        VStack {
            Button("run session") {
                store.send(.runARSession)
            }
            Button("mesh tracking") {
                store.send(.toggleMeshTracking(true))
            }
            Button("plane tracking") {
                store.send(.togglePlaneTracking(true))
            }
            Button("world tracking") {
                store.send(.toggleWorldTracking(true))
            }
        }
        .navigationTitle("Debug menu")
    }
}
