//
//  AnimationResourceExtensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import RealityKit
import Foundation

public extension AnimationResource {
    /// - Warning: This is only useful when ``CustomTimingFunction`` is ``.easeXXXBounce`` or fully custom, as ``FromToByAnimation``  should be more flexible for all use cases.
    static func sampledFromTo(name: String = "", from: Transform? = nil, to: Transform? = nil, duration: TimeInterval = 1.0, timing: CustomTimingFunction = .linear, tweenMode: TweenMode = .linear, frameInterval: Float = 0.01, isAdditive: Bool = false, blendLayer: Int32 = 0, repeatMode: AnimationRepeatMode = .none, fillMode: AnimationFillMode = [], trimStart: TimeInterval? = nil, trimEnd: TimeInterval? = nil, trimDuration: TimeInterval? = nil, offset: TimeInterval = 0, delay: TimeInterval = 0, speed: Float = 1.0) -> AnimationResource? {
        let anim = SampledAnimation<Transform>.fromTo(name: name, from: from, to: to, duration: duration, timing: timing, tweenMode: tweenMode, frameInterval: frameInterval, isAdditive: isAdditive, blendLayer: blendLayer, repeatMode: repeatMode, fillMode: fillMode, trimStart: trimStart, trimEnd: trimEnd, trimDuration: trimDuration, offset: offset, delay: delay, speed: speed)
        return try? .generate(with: anim)
    }
}
