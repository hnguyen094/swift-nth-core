//
//  AnimationTimingFunctionExtensions.swift
//  
//
//  Created by hung on 6/27/24.
//
//  https://easings.net ; missing elastic and bounce, and we should use CustomTimingFunction
//  Note that this does NOT match https://matthewlein.com/tools/ceaser
//

import RealityKit

public extension AnimationTimingFunction {
    static var easeInSine: Self {
        .cubicBezier(controlPoint1: [0.12, 0], controlPoint2: [0.39, 0])
    }
    static var easeOutSine: Self {
        .cubicBezier(controlPoint1: [0.61, 1], controlPoint2: [0.88, 1])
    }
    static var easeInOutSine: Self {
        .cubicBezier(controlPoint1: [0.37, 0], controlPoint2: [0.63, 1])
    }
    static var easeInQuad: Self {
        .cubicBezier(controlPoint1: [0.11, 0], controlPoint2: [0.5, 0])
    }
    static var easeOutQuad: Self {
        .cubicBezier(controlPoint1: [0.5, 1], controlPoint2: [0.89, 1])
    }
    static var easeInOutQuad: Self {
        .cubicBezier(controlPoint1: [0.45, 0], controlPoint2: [0.55, 1])
    }
    static var easeInCubic: Self {
        .cubicBezier(controlPoint1: [0.32, 0], controlPoint2: [0.67, 0])
    }
    static var easeOutCubic: Self {
        .cubicBezier(controlPoint1: [0.33, 1], controlPoint2: [0.68, 1])
    }
    static var easeInOutCubic: Self {
        .cubicBezier(controlPoint1: [0.65, 0], controlPoint2: [0.35, 1])
    }
    static var easeInQuart: Self {
        .cubicBezier(controlPoint1: [0.5, 0], controlPoint2: [0.75, 0])
    }
    static var easeOutQuart: Self {
        .cubicBezier(controlPoint1: [0.25, 1], controlPoint2: [0.5, 1])
    }
    static var easeInOutQuart: Self {
        .cubicBezier(controlPoint1: [0.76, 0], controlPoint2: [0.24, 1])
    }
    static var easeInQuint: Self {
        .cubicBezier(controlPoint1: [0.64, 0], controlPoint2: [0.78, 0])
    }
    static var easeOutQuint: Self {
        .cubicBezier(controlPoint1: [0.22, 1], controlPoint2: [0.36, 1])
    }
    static var easeInOutQuint: Self {
        .cubicBezier(controlPoint1: [0.83, 0], controlPoint2: [0.17, 1])
    }
    static var easeInExpo: Self {
        .cubicBezier(controlPoint1: [0.7, 0], controlPoint2: [0.84, 0])
    }
    static var easeOutExpo: Self {
        .cubicBezier(controlPoint1: [0.16, 1], controlPoint2: [0.3, 1])
    }
    static var easeInOutExpo: Self {
        .cubicBezier(controlPoint1: [0.87, 0], controlPoint2: [0.13, 1])
    }
    static var easeInCirc: Self {
        .cubicBezier(controlPoint1: [0.55, 0], controlPoint2: [1, 0.45])
    }
    static var easeOutCirc: Self {
        .cubicBezier(controlPoint1: [0, 0.55], controlPoint2: [0.45, 1])
    }
    static var easeInOutCirc: Self {
        .cubicBezier(controlPoint1: [0.85, 0], controlPoint2: [0.15, 1])
    }
    static var easeInBack: Self {
        .cubicBezier(controlPoint1: [0.36, 0], controlPoint2: [0.66, -0.56])
    }
    static var easeOutBack: Self {
        .cubicBezier(controlPoint1: [0.34, 1.56], controlPoint2: [0.64, 1])
    }
    static var easeInOutBack: Self {
        .cubicBezier(controlPoint1: [0.68, -0.6], controlPoint2: [0.32, 1.6])
    }
}
