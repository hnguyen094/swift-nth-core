//
//  ReproducibleRandomSource.swift
//  keepers
//
//  Created by Hung on 10/6/23.
//

import GameplayKit

public protocol GKRandomCopyable: GKRandom, NSMutableCopying, Equatable {}

public class ReproducibleRandomSource: GKRandomCopyable {
    private var seed: UInt64

    // note: not used in equatable definition
    private let source: GKRandom
    private let sourceType: GKSourceType
    private(set) var history = [FnType]()
    
    public init(seed: UInt64, with sourceType: GKSourceType) {
        self.seed = seed

        source = switch sourceType {
        case .ARC4:
            GKARC4RandomSource(seed: Data(bytes: &self.seed, count: MemoryLayout<UInt64>.size))
        case .LinearCongruential:
            GKLinearCongruentialRandomSource(seed: seed)
        case .MersenneTwister:
            GKMersenneTwisterRandomSource(seed: seed)
        }
        self.sourceType = sourceType
    }
    
    public func nextInt() -> Int {
        history.append(.nextInt)
        return source.nextInt()
    }
    
    public func nextInt(upperBound: Int) -> Int {
        history.append(.nextIntWithUpperBound(upperBound: upperBound))
        return source.nextInt(upperBound: upperBound)
    }
    
    public func nextUniform() -> Float {
        history.append(.nextUniform)
        return source.nextUniform()
    }
    
    public func nextBool() -> Bool {
        history.append(.nextBool)
        return source.nextBool()
    }
    
    public enum GKSourceType {
        case ARC4
        case LinearCongruential
        case MersenneTwister
    }
    
    public enum FnType: Equatable {
        case nextInt
        case nextIntWithUpperBound(upperBound: Int)
        case nextUniform
        case nextBool
    }
}

extension ReproducibleRandomSource: NSMutableCopying {
    public func mutableCopy(with zone: NSZone? = nil) -> Any {
        let copy = ReproducibleRandomSource(seed: self.seed, with: self.sourceType)
        copy.update(with: self.history)
        return copy
    }
    
    private func update(with history: [FnType]) {
        for call in history {
            switch call {
            case .nextBool:
                source.nextBool()
            case .nextInt:
                source.nextInt()
            case .nextIntWithUpperBound(let upperBound):
                source.nextInt(upperBound: upperBound)
            case .nextUniform:
                source.nextUniform()
            }
        }
        self.history = history
    }
}

extension ReproducibleRandomSource: Equatable {
    public static func == (lhs: ReproducibleRandomSource, rhs: ReproducibleRandomSource) 
    -> Bool {
        lhs.seed == rhs.seed && lhs.sourceType == rhs.sourceType &&
            lhs.history == rhs.history
    }
}
