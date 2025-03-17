//
//  TransformExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 3/17/25.
//

import RealityKit

// MARK: Lerp
public extension Transform {
    func lerp(to end: Transform, t value: Float) -> Transform {
        return Transform(
            scale: mix(self.scale, end.scale, t: value),
            rotation: simd_slerp(self.rotation, end.rotation, value),
            translation: mix(self.translation, end.translation, t: value)
        )
    }
}
