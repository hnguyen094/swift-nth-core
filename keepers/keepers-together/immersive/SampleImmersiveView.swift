//
//  SampleImmersiveView.swift
//  keepers:together
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct SampleImmersiveView: View {
    static let Id: String = "SampleImmersiveSpace"
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(scene)
            }
        }
    }
}

#Preview {
    SampleImmersiveView()
        .previewLayout(.sizeThatFits)
}
