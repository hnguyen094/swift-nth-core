//
//  AnimationDefinitionExtensions.swift
//  
//
//  Created by hung on 6/27/24.
//

import RealityKit
import Foundation

public extension AnimationDefinition {
    @MainActor
    func asAnimationResource() -> AnimationResource? {
        return try? .generate(with: self)
    }
}

public extension SampledAnimation<Transform> {
    static func fromTo(name: String = "", from: Transform? = nil, to: Transform? = nil, duration: TimeInterval = 1.0, timing: CustomTimingFunction = .linear, tweenMode: TweenMode = .linear, frameInterval: Float = 0.01, isAdditive: Bool = false, blendLayer: Int32 = 0, repeatMode: AnimationRepeatMode = .none, fillMode: AnimationFillMode = [], trimStart: TimeInterval? = nil, trimEnd: TimeInterval? = nil, trimDuration: TimeInterval? = nil, offset: TimeInterval = 0, delay: TimeInterval = 0, speed: Float = 1.0) -> Self {

        var frames: [Transform] = []
        let start = from ?? Transform()
        let end = to ?? Transform(translation: .one)

        let fDuration = Float(duration)

        for t: Float in stride(from: 0, to: fDuration, by: frameInterval) {
            let normalizedValue = Float(timing.fn(TimeInterval(t / fDuration)))
            let sample = Transform(
                scale: start.scale + (end.scale - start.scale) * normalizedValue,
                rotation: simd_slerp(start.rotation, end.rotation, normalizedValue),
                translation: start.translation + (end.translation - start.translation) * normalizedValue
            )
            frames.append(sample)
        }

        return SampledAnimation(
            frames: frames,
            name: name,
            tweenMode: tweenMode,
            frameInterval: frameInterval,
            isAdditive: isAdditive,
            bindTarget: .transform,
            blendLayer: blendLayer,
            repeatMode: repeatMode,
            fillMode: fillMode,
            trimStart: trimStart,
            trimEnd: trimEnd,
            trimDuration: trimDuration,
            offset: offset,
            delay: delay,
            speed: speed
        )
    }
}
