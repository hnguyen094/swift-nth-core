//
//  SampleImmersiveView.swift
//  keepers:together
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import RealityKit

struct SampleImmersiveView: View {
    static let Id: String = "SampleImmersiveSpace"
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
        }
    }
}

#Preview {
    SampleImmersiveView()
        .previewLayout(.sizeThatFits)
}
