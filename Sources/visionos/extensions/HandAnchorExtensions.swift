//
//  HandAnchor.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 1/3/25.
//

import ARKit
import RealityKit

public extension HandAnchor {
    /// The location and orientation of a joint in world space.
    func transform(joint named: HandSkeleton.JointName) -> Transform? {
        guard let skeleton = handSkeleton else { return .none }
        let matrix = originFromAnchorTransform * skeleton.joint(named).anchorFromJointTransform
        return .init(matrix: matrix)
    }
}
