//
//  PlaneAnchorExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 1/3/25.
//

import ARKit
import RealityKit

public extension PlaneAnchor {
    /// Computed world space transform for a rectangular prism of dimensions `[extent.width, extent.height, 1]`.
    var extentTransform: simd_float4x4 {
        let extent = geometry.extent
        let local = Transform(scale: [extent.width, extent.height, 1])
        let anchoredTransform = extent.anchorFromExtentTransform * local.matrix
        let extentTransform = originFromAnchorTransform * anchoredTransform
        return extentTransform
    }
}
