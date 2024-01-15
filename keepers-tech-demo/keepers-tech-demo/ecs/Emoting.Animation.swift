//
//  Emoting.Animation.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import RealityKit

extension Emoting {
    enum Animation: CaseIterable, Hashable {
        case idle
        case slowLookAround
        case backflip
        case headShake
        case doubleNod
        case headbang
        case dance
        case sad
        case excitedBounce
        case curiousHeadTilt
        case transitioning
    }
}

extension Emoting.System {
    static func returnAnimation(from: Transform) -> AnimationResource? {
        .sampledFromTo(
            from: from,
            to: .identity,
            duration: 0.25,
            timing: .easeInOutSine
        )
    }
    
    // MARK: idle
    fileprivate static let idle: AnimationResource? = try? .sequence(with: [
        .sampledFromTo(
            to: Transform(translation: [0, 0.01, 0]),
            duration: 2,
            timing: .easeInOutSine,
            repeatMode: .autoReverse,
            trimDuration: 10
        )
        // TODO: add a flare idle animation here
    ].compact())
    
    // MARK: slowLookAround
    fileprivate static let slowLookAround: AnimationResource? =
        try? .group(with: [
            try? .sequence(with: [
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: .pi / 8, axis: [0, 1, 0])),
                    duration: 0.5,
                    trimDuration: 5
                ),
                .sampledFromTo(
                    from: Transform(rotation: .init(angle: .pi / 8, axis: [0, 1, 0])),
                    to: Transform(rotation: .init(angle: -.pi / 8, axis: [0, 1, 0])),
                    trimDuration: 5
                ),
                .sampledFromTo(
                    from: Transform(rotation: .init(angle: -.pi / 8, axis: [0, 1, 0])),
                    to: .identity,
                    duration: 0.5
                )
            ].compact()).repeat(),
            try? .sequence(with: [
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: .pi / 16, axis: [1, 0, 0])),
                    duration: 0.5,
                    isAdditive: true,
                    trimDuration: 15
                ),
                .sampledFromTo(
//                    from: Transform(rotation: .init(angle: .pi / 16, axis: [1, 0, 0])),
                    to: Transform(rotation: .init(angle: -.pi / 8, axis: [1, 0, 0])),
                    isAdditive: true,
                    trimDuration: 15
                ),
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: .pi / 16, axis: [1, 0, 0])),
                    duration: 0.5,
                    isAdditive: true
                )
            ].compact()).repeat()
        ].compact())
    
    static let animations: [Emoting.Animation: AnimationResource?] = [
        .idle: Self.idle,
        
        .slowLookAround: Self.slowLookAround,
        
        // MARK: backflip
        .backflip: try? .sequence(with: [
            .sampledFromTo(
                to: Transform(translation: [0, 0.025, 0.01]),
                duration: 0.1,
                timing: .easeOutSine),
            .sampledFromTo(
                from: Transform(translation: [0, 0.025, 0.01]),
                to: Transform(translation: [0, 0, 0.02]),
                duration: 0.1,
                timing: .easeInSine),
            .sampledFromTo(
                from: Transform(translation: [0, 0, 0.02]),
                to: Transform(scale: [1, 0.85, 1], translation: [0, -0.0075, 0.02]),
                duration: 1.5,
                timing: .easeOutBack),
            try? .group(with: [
                try? .sequence(with: [
                    .sampledFromTo(
                        from: Transform(scale: [1, 0.85, 1], translation: [0, 0, 0.02]),
                        to: Transform(scale: [1, 1.15, 1], translation: [0, 0.05, 0.01]),
                        duration: 0.5,
                        timing: .easeOutCircle),
                    .sampledFromTo(
                        from: Transform(scale: [1, 1.15, 1], translation: [0, 0.05, 0.01]),
                        to: .identity,
                        timing: .easeOutBounce)
                ].compact()),
                try? .sequence(with: [
                    .sampledFromTo(
                        from: Transform(),
                        to: Transform(
                            rotation: .init(angle: -.pi, axis: [1, 0, 0])),
                        duration: 0.5,
                        timing: .easeInCircle,
                        frameInterval: 0.00001,
                    isAdditive: true),
                    .sampledFromTo(
                        from: Transform(
                            rotation: .init(angle: -.pi, axis: [1, 0, 0])),
                        to: Transform(
                            rotation: .init(angle: -2 * .pi, axis: [1,0,0])),
                        duration: 0.5,
                        timing: .easeOutCircle,
                        frameInterval: 0.00001,
                    isAdditive: true),
                    .sampledFromTo(
                        from: .identity,
                        to: .identity,
                        duration: 0)
                ].compact())
            ].compact())
        ].compact()),
        
        // MARK: headShake
        .headShake: try? .sequence(with: [
            .sampledFromTo( 
                to: Transform(rotation: .init(angle: .pi / 8, axis: [0, 1, 0])),
                duration: 0.2),
            .sampledFromTo(
                to: Transform(rotation: .init(angle: -.pi / 4, axis: [0, 1, 0])),
                duration: 0.2,
                isAdditive: true),
            .sampledFromTo(
                to: Transform(rotation: .init(angle: 3 * .pi / 16, axis: [0, 1, 0])),
                duration: 0.2,
                isAdditive: true),
            .sampledFromTo(
                to: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 1, 0])),
                duration: 0.2,
                isAdditive: true),
            .sampledFromTo(
                to: .identity,
                duration: 1.2,
                isAdditive: true)
        ].compact()),
        
        // MARK: doubleNod
        .doubleNod: try? .sequence(with: [
            .sampledFromTo(
                to: Transform(rotation: .init(angle: .pi / 8, axis: [1, 0, 0])),
                duration: 0.25,
                repeatMode: .autoReverse,
                trimDuration: 1),
            .sampledFromTo(
                to: .identity,
                duration: 1.5,
                isAdditive: true)
        ].compact()),
        
        // MARK: headbang
        
        .headbang: 
            try? .sequence(with: [
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                    duration: 0.1
                ),
                .sampledFromTo(
                    from: Transform(rotation: .init(angle: -.pi / 32, axis: [0, 0, 1])),
                    to: Transform(rotation: .init(angle: .pi / 6, axis: [1, 0, -0.1875])),
                    duration: 0.25,
                    repeatMode: .autoReverse,
                    trimDuration: .infinity)
            ].compact()),
        
        // MARK: dance
        .dance: try? .sequence(with: [
            try? .group(with: [
                .sampledFromTo(
                    to: Transform(translation: [0.05, 0, 0]),
                    duration: 0.5,
                    timing: .easeInCircle,
                    trimDuration: 0.85),
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: .pi / 16, axis: [0, 0, 1])),
                    duration: 0.5,
                    timing: .easeOutCubic,
                    isAdditive: true,
                    repeatMode: .autoReverse,
                    trimDuration: 1,
                    speed: 2)
            ].compact()),
            try? .group(with: [
                .sampledFromTo(
                    to: Transform(translation: [-0.05, 0, 0]),
                    duration: 0.5,
                    timing: .easeInCircle,
                    isAdditive: true,
                    repeatMode: .none,
                    trimDuration: 0.85),
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                    duration: 0.5,
                    timing: .easeOutCubic,
                    isAdditive: true,
                    repeatMode: .autoReverse,
                    trimDuration: 1,
                    speed: 2)
            ].compact()),
            try? .group(with: [
                .sampledFromTo(
                    to: Transform(translation: [-0.05, 0, 0]),
                    duration: 0.5,
                    timing: .easeInCircle,
                    isAdditive: true,
                    repeatMode: .none,
                    trimDuration: 0.85),
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: -.pi / 16, axis: [0, 0, 1])),
                    duration: 0.5,
                    timing: .easeOutCubic,
                    isAdditive: true,
                    repeatMode: .autoReverse,
                    trimDuration: 1,
                    speed: 2)
            ].compact()),
            try? .group(with: [
                .sampledFromTo(
                    to: Transform(translation: [0.05, 0, 0]),
                    duration: 0.5,
                    timing: .easeInCircle,
                    isAdditive: true,
                    trimDuration: 0.85),
                .sampledFromTo(
                    to: Transform(rotation: .init(angle: .pi / 16, axis: [0, 0, 1])),
                    duration: 0.5,
                    timing: .easeOutCubic,
                    isAdditive: true,
                    repeatMode: .autoReverse,
                    trimDuration: 1,
                    speed: 2)
            ].compact())
        ].compact()),

        // MARK: sad
        .sad: try? .sequence(with: [
            .sampledFromTo(
            to: Transform(
                rotation: .init(angle: .pi / 4, axis: [1, 0, 0]),
                translation: [0, 0, -0.02]),
            duration: 2,
            timing: .easeOutCubic),
            try? .sequence(with: [
                .sampledFromTo(
                    from: Transform(
                        rotation: .init(angle: .pi / 4, axis: [1, 0, 0]),
                        translation: [0, 0, -0.02]),
                    to: Transform(
                        rotation: .init(angle: .pi / 4, axis: [1, 0.1, 0]),
                        translation: [0, 0, -0.02]),
                    duration: 0.2),
                .sampledFromTo(
                    from: Transform(
                        rotation: .init(angle: .pi / 4, axis: [1, 0.1, 0]),
                        translation: [0, 0, -0.02]),
                    to: Transform(
                        rotation: .init(angle: .pi / 4, axis: [1, -0.1, 0]),
                        translation: [0, 0, -0.02]),
                    duration: 0.4),
                .sampledFromTo(
                    from: Transform(
                        rotation: .init(angle: .pi / 4, axis: [1, -0.1, 0]),
                        translation: [0, 0, -0.02]),
                    to: Transform(
                        rotation: .init(angle: .pi / 4, axis: [1, 0, 0]),
                        translation: [0, 0, -0.02]),
                    duration: 0.2,
                    trimDuration: 3)
            ].compact()).repeat()
        ].compact()),
        
        // MARK: excitedBounce
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
        ].compact()),
        
        // MARK: curiousHeadTilt
        .curiousHeadTilt: try? .sequence(with: [
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
        ].compact())
    ]
}
