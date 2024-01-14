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
            case next
        }
        
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .setEmotionAnimation(let newValue):
                    state.emotionAnimation = newValue
                    return .none
                case .next:
                    let index = Emoting.Animation.allCases.firstIndex(of: state.emotionAnimation)!
                    state.emotionAnimation = Emoting.Animation.allCases[(index + 1) % (Emoting.Animation.allCases.count - 1)]
                    return .none
                }
            }
        }
    }
}
