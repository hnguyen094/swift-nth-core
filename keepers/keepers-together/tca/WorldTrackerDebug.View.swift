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
        List {
            Button("run session") {
                store.send(.toggleMeshTracking(true))
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
    }
}
