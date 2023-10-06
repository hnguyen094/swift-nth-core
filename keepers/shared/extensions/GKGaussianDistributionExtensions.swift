//
//  GKGaussianDistributionExtensions.swift
//  keepers
//
//  Created by Hung on 10/6/23.
//
//  This is truly, truly evil.

import GameplayKit

///  Provides ``nextFloat()`` to ``GKGaussianDistribution``.
class GaussianDistribution: GKGaussianDistribution {
    private let randomSource: GKRandom
    
    override init(randomSource source: GKRandom, lowestValue lowestInclusive: Int, highestValue highestInclusive: Int) {
        randomSource = source
        super.init(randomSource: source, lowestValue: lowestInclusive, highestValue: highestInclusive)
    }
    
    override init(randomSource source: GKRandom, mean: Float, deviation: Float) {
        randomSource = source
        super.init(randomSource: randomSource, mean: mean, deviation: deviation)
    }
    
    /// Generates and returns a new random float within the bounds of the distribution.
    ///
    /// This uses Box-Muller to generate a pair of independent Gaussians, but we only compute and return
    /// one of them.
    func nextFloat() -> Float {
        guard deviation > 0 else { return mean }
        
        let x1 = randomSource.nextUniform()
        let x2 = randomSource.nextUniform()
        let z1 = sqrt(-2 * log(x1)) * cos(2 * .pi * x2)
        
        return z1 * deviation + mean
    }
}
