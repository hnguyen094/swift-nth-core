//
//  ImmersiveView.swift
//  dimensions
//
//  Created by hung on 2/6/24.
//

import SwiftUI
import ComposableArchitecture

struct ImmersiveView: View {
    @Bindable var store: StoreOf<dimensionsApp.Feature>

    var mode: StoreOf<dimensionsApp.Mode> {
        store.scope(state: \.mode, action: \.mode)
    }

    var body: some View {
        switch mode.state {
        case .planes:
            if let planeMeasure = mode.scope(state: \.planes, action: \.planes) {
                PlaneMeasureView(store: planeMeasure, usesMetricSystem: $store.usesMetricSystem)
            }
        case .meshes:
            if let meshMeasure = mode.scope(state: \.meshes, action: \.meshes) {
                MeshMeasureView(store: meshMeasure, usesMetricSystem: $store.usesMetricSystem)
            }
        }
    }
}

#Preview {
    ImmersiveView(store: .init(initialState: .init(), reducer: {
        dimensionsApp.Feature()
    }))
    .previewLayout(.sizeThatFits)
}
