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
        case excitedBounce
        
        case transitioning
    }
}

extension Emoting.System {
    static let animations: [Emoting.Animation: AnimationResource?] = [
        .idle: try? .sequence(with: [
            .sampledFromTo(
                to: Transform(rotation: .init(angle: .pi / 16, axis: [0, 0, 1])),
                speed: 4),
            .sampledFromTo(
                from: Transform(rotation: .init(angle: .pi / 16, axis: [0, 0, 1])),
                to: Transform(rotation: .init(angle: .pi / 16, axis: [0, 0, 1])),
                duration: 5,
                speed: 4),
            .sampledFromTo(
                from: Transform(rotation: .init(angle: .pi / 16, axis: [0, 0, 1])),
                to: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                duration: 2,
                speed: 4),
            .sampledFromTo(
                from: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                to: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                duration: 5,
                speed: 4),
            .sampledFromTo(
                from: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                to: .identity,
                speed: 4)
        ].compact()),

        .excitedBounce: try? .group(with: [
            .sampledFromTo(
                to: Transform(translation: [0, 0.05, 0]),
                timing: .easeOutCubic,
                isAdditive: true,
                repeatMode: .autoReverse,
                trimDuration: 4,
                speed: 4),
            try? .sequence(with: [
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: .pi / 8, axis: [-0.5, 1, 0])),
                    timing: .easeOutSine,
                    repeatMode: .autoReverse,
                    trimDuration: 2,
                    speed: 4),
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: -.pi / 8, axis: [0.5, 1, 0])),
                    timing: .easeOutSine,
                    repeatMode: .autoReverse,
                    trimDuration: 2,
                    speed: 4)
            ].compact())
        ].compact())
    ]
    
    static func returnAnimation(from: Transform) -> AnimationResource? {
        .sampledFromTo(
            from: from,
            to: .identity,
            duration: 0.25,
            timing: .easeInOutSine
        )
    }
}
