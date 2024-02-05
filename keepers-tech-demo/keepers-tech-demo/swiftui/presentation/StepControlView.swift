//
//  StepControlView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

extension demoApp {
    struct StepControlView: View {
        typealias Step = demoApp.Step
        @Bindable var store: StoreOf<Feature>

        var body: some View {
            HStack {
                Text("Configuration complete.")
            }
            .toolbar {
                demoApp.ornamentButtons(store, demoApp.stepData[store.step]?.buttons)
            }
            .frame(idealWidth: 300, idealHeight: 300)
        }
    }
}
