//
//  ImmersiveView.swift
//  dimensions
//
//  Created by hung on 2/6/24.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            content.add(ModelEntity(mesh: .generateSphere(radius: 0.1), materials: [PhysicallyBasedMaterial()]))
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
