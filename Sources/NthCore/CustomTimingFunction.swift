//
//  CustomTimingFunction.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import Foundation

public struct CustomTimingFunction {
    public var fn: (TimeInterval) -> Double
    
    public init(_ fn: @escaping (TimeInterval) -> Double) {
        self.fn = fn
    }
    
    public static let linear: Self = .init { $0 }
    
    public static let easeInSine: Self = .init { 1 - cos(($0 * .pi) / 2) }
    public static let easeOutSine: Self = .init { sin(($0 * .pi) / 2) }
    public static let easeInOutSine: Self = .init { -(cos(.pi * $0) - 1) / 2 }

    
    public static let easeInCubic: Self = .init { pow($0, 3) }
    public static let easeOutCubic: Self = .init { 1 - pow(1 - $0, 3) }
    public static let easeInOutCubic: Self = .init { t in
        t < 0.5
        ? 4 * pow(t, 3)
        : 1 - pow(-2 * t + 2, 3) / 2
    }
    
    // https://blog.maximeheckel.com/posts/cubic-bezier-from-math-to-motion/
    public static func cubicBezier(p1: SIMD2<Double>, p2: SIMD2<Double>) -> Self {
        .init { t in
            pow(1-t, 3) * p1.x + t * p1.y * 3 * pow(1-t, 2) + p2.x * 3 * (1-t) * pow(t, 2) + p2.y * pow(t, 3)
        }
    }
    
    // https://easings.net
    private static let c1: Double = 1.70158
    private static let c2: Double = c1 * 1.525
    private static let c3: Double = c1 + 1
    private static let c4: Double = 2 * Double.pi / 3
    private static let c5: Double = 2 * Double.pi / 4.5
    private static let n1: Double = 7.5625
    private static let d1: Double = 2.75
    
    public static let easeInCircle: Self = .init { 1 - sqrt(1 - pow($0, 2)) }
    public static let easeOutCircle: Self = .init { sqrt(1 - pow($0 - 1, 2)) }
    public static let easeInOutCircle: Self = .init { t in
        t < 0.5
        ? (1 - sqrt(1 - pow(2 * t, 2))) / 2
        : (sqrt(1 - pow(-2 * t + 2, 2)) + 1) / 2
    }

    public static let easeInBack: Self = .init { Self.c3 * pow($0, 3) - Self.c1 * pow($0, 2) }
    public static let easeOutBack: Self = .init { 1 + Self.c3 * pow($0 - 1, 3) + Self.c1 * pow($0 - 1, 2) }
    public static let easeInOutBack: Self = .init { t in
        if t < 0.5 {
            (pow(2 * t, 2) * ((Self.c2 + 1) * 2 * t - Self.c2)) / 2
        } else {
            (pow(2 * t - 2, 2) * ((Self.c2 + 1) * (t * 2 - 2) + Self.c2) + 2) / 2
        }
    }
    
    public static let easeInBounce: Self = .init { 1 - Self.easeOutBounce.fn(1 - $0) }
    public static let easeOutBounce: Self = .init { t in
        if (t < 1 / Self.d1) {
            return Self.n1 * t * t
        } else if (t < 2 / Self.d1) {
            let _t = t - 1.5 / Self.d1
            return Self.n1 * _t * _t + 0.75
        } else if (t < 2.5 / Self.d1) {
            let _t = t - 2.25 / Self.d1
            return Self.n1 * _t * _t + 0.9375
        } else {
            let _t = t - 2.625 / Self.d1
            return Self.n1 * _t * _t + 0.984375
        }
    }
    public static let easeInOutBounce: Self = .init { t in
        t < 0.5
        ? (1 - Self.easeOutBounce.fn(1 - 2 * t)) / 2
        : (1 + Self.easeOutBounce.fn(2 * t - 1)) / 2
    }

    public static let easeInElastic: Self = .init { t in
        t == 0
        ? 0
        : t == 1
        ? 1
        : -pow(2, 10 * t - 10) * sin((t * 10 - 10.75) * Self.c4)
    }
    
    public static let easeOutElastic: Self = .init { t in
        t == 0
        ? 0
        : t == 1
        ? 1
        : pow(2, -10 * t) * sin((t * 10 - 0.75) * Self.c4) + 1
    }
    
    public static let easeInOutElastic: Self = .init { t in
        t == 0
        ? 0
        : t == 1
        ? 1
        : t < 0.5
        ? -(pow(2, 20 * t - 10) * sin((20 * t - 11.125) * Self.c5)) / 2
        : (pow(2, -20 * t + 10) * sin((20 * t - 11.125) * Self.c5)) / 2 + 1
    }
}
