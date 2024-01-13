//
//  Creature.Feature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import ComposableArchitecture

extension Creature {
    @Reducer
    struct Feature {
        struct State: Equatable {
            var emotionAnimation: Emoting.Animation = .idle
        }
        
        enum Action {
            case setEmotionAnimation(Emoting.Animation)
            case setRandom
        }
        
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .setEmotionAnimation(let newValue):
                    state.emotionAnimation = newValue
                    return .none
                case .setRandom:
                    state.emotionAnimation = state.emotionAnimation == .idle ? .excitedBounce : .idle
                    return .none
                }
            }
        }
    }
}
