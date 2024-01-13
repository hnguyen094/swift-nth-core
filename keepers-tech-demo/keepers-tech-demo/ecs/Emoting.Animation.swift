//
//  Emoting.Animation.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import RealityKit

extension Emoting {
    enum Animation: Hashable {
        case idle
        case bounce
    }
}

extension Emoting.System {
    static let animations: [Emoting.Animation: AnimationResource?] = [
        .bounce: .fromToAnimation(
            from: Transform(translation: [0, 0, 0]),
            to: Transform(translation: [0, 0, 0.3]),
            duration: 3,
            timing: .easeInBounce,
            repeatMode: .autoReverse)
    ]
}
