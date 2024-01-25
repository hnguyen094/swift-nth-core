//
//  Creature.ImmersiveView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ComposableArchitecture

extension Creature {
    struct ImmersiveView: SwiftUI.View {
        let store: StoreOf<Creature.Feature>

        var body: some SwiftUI.View {
            Creature.View(store: store)
        }
    }
}

#Preview {
    Creature.ImmersiveView(store: Store(initialState: Creature.Feature.State(), reducer: { Creature.Feature() }))
        .previewLayout(.sizeThatFits)
}
