//
//  GKGaussianDistributionExtensions.swift
//  keepers
//
//  Created by Hung on 10/6/23.
//

import GameplayKit

///  Provides ``nextFloat()`` to ``GKGaussianDistribution``.
///  
///  - Author: [Code Different](https://stackoverflow.com/a/49471411) (with modifications)
public class GaussianDistribution: GKGaussianDistribution {
    private let randomSource: GKRandom
    
    public override init(randomSource source: GKRandom, lowestValue lowestInclusive: Int, highestValue highestInclusive: Int) {
        randomSource = source
        super.init(randomSource: source, lowestValue: lowestInclusive, highestValue: highestInclusive)
    }
    
    public override init(randomSource source: GKRandom, mean: Float, deviation: Float) {
        precondition(deviation >= 0)
        randomSource = source
        super.init(randomSource: randomSource, mean: mean, deviation: deviation)
    }
    
    public override func copy() -> Any {
        guard let source = randomSource as? any GKRandomCopyable else {
            return super.copy()
        }
        return GaussianDistribution(
            randomSource: source.mutableCopy() as! GKRandom,
            mean: mean,
            deviation: deviation)
    }
    
    /// Generates and returns a new random float within the bounds of the distribution.
    ///
    /// This uses Box-Muller to generate a pair of independent Gaussians, but we only compute and return
    /// one of them. We also clamp the result to within 3 standard deviations as the other functions.
    public func nextFloat() -> Float {
        guard deviation > 0 else { return mean }
        
        let x1 = randomSource.nextUniform()
        let x2 = randomSource.nextUniform()
        let z1 = sqrt(-2 * log(x1)) * cos(2 * .pi * x2)
        
        return (z1 * deviation + mean)
            .clamped(to: (mean - 3 * deviation)...(mean + 3 * deviation))
    }
}
