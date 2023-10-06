//
//  ReproducibleRandomSource.swift
//  keepers
//
//  Created by Hung on 10/6/23.
//

import GameplayKit

protocol GKRandomCopyable: GKRandom, NSMutableCopying {}

class ReproducibleRandomSource: GKRandomCopyable {
    private var seed: UInt64

    private let source: GKRandom
    private let sourceType: GKSourceType
    private(set) var history = [FnType]()
    
    init(seed: UInt64, with sourceType: GKSourceType) {
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
    
    func nextInt() -> Int {
        history.append(.nextInt)
        return source.nextInt()
    }
    
    func nextInt(upperBound: Int) -> Int {
        history.append(.nextIntWithUpperBound(upperBound: upperBound))
        return source.nextInt(upperBound: upperBound)
    }
    
    func nextUniform() -> Float {
        history.append(.nextUniform)
        return source.nextUniform()
    }
    
    func nextBool() -> Bool {
        history.append(.nextBool)
        return source.nextBool()
    }
    
    enum GKSourceType {
        case ARC4
        case LinearCongruential
        case MersenneTwister
    }
    
    enum FnType {
        case nextInt
        case nextIntWithUpperBound(upperBound: Int)
        case nextUniform
        case nextBool
    }
}

extension ReproducibleRandomSource: NSMutableCopying {
    func mutableCopy(with zone: NSZone? = nil) -> Any {
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
