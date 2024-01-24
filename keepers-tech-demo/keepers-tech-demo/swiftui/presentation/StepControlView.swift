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
        let store: StoreOfView

        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                HStack {
                    Text("Demo complete.")
                }
                .toolbar {
                    demoApp.ornamentButtons(store, demoApp.stepData[viewStore.step]?.buttons)
                }
            }
            .frame(idealWidth: 300, idealHeight: 300)
        }
    }
}
