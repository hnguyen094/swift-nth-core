//
//  FlatView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

extension demoApp {
    struct FlatView: View {
        @Bindable var store: StoreOf<Feature>
        
        var body: some View {
            switch store.step {
            case .heroScreen:
                StepHeroView(store: store)
            case .controls:
                StepControlView(store: store)
            default:
                StepBasicView(store: store)
            }
        }
    }
}
