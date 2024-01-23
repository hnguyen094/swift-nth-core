//
//  Creature.ImmersiveView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

extension Creature {
    struct ImmersiveView: View {
        var body: some View {
            RealityView { content in
                // Add the initial RealityKit content
                if let scene = try? await RealityKit.Entity(named: "Immersive", in: realityKitContentBundle) {
                    content.add(scene)
                }
            }
        }
    }
}

#Preview {
    Creature.ImmersiveView()
        .previewLayout(.sizeThatFits)
}
