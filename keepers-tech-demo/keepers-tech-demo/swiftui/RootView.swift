//
//  RootView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

struct RootView: View {
    let store: StoreOf<keepers_tech_demoApp.Feature>

    var body: some View {
//        Toggle(isOn: $showImmersiveSpace) {
//            Text("Show Immersive Space")
//        }
//        .toggleStyle(.button)
//        .glassBackgroundEffect()

        WithViewStore(store, observe: \.step) { viewStore in
            switch viewStore.state {
            case .heroScreen:
                Step_HeroScreen(store: store)
            case .complete:
                Text("Demo complete.")
            default:
                StepView(store: store.scope(state: \.viewState, action: \.self))
            }
        }
    }
}
