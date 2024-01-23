//
//  RootView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

extension demoApp {
    struct RootView: View {
        let store: StoreOf<demoApp.Feature>
        
        var body: some View {
            WithViewStore(store, observe: \.step) { viewStore in
                let scopedStore = store.scope(state: \.viewState, action: \.self)
                switch viewStore.state {
                case .heroScreen:
                    StepHeroView(store: store)
                case .controls:
                    StepControlView(store: scopedStore)
                default:
                    StepBasicView(store: scopedStore)
                }
            }
        }
    }
}
