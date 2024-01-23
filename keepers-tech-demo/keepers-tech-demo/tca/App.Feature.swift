//
//  App.Feature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

import ComposableArchitecture

extension keepers_tech_demoApp {
    @Reducer
    struct Feature: Reducer {
        struct State: Equatable {
            var step: Step
            var name: String
        }
        
        enum Action {
            case next
            case skipAll
        }
        
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .next:
                    state.step.next()
                    return .none
                case .skipAll:
                    state.step = Step.allCases.last!
                    return .none
                }
            }
        }
    }
}

extension keepers_tech_demoApp {
    enum Step: Int, CaseIterable, Comparable, Equatable {
        case heroScreen
        case welcomeAbstract
        case volumeIntro
        case immersiveIntro
        case soundAnalyserIntro
        case meshClassificationIntro
        case futureDevelopment
        case complete
        
        mutating func next() {
            self = Self(rawValue: self.rawValue + 1) ?? Self.allCases.last!
        }
        
        mutating func previous() {
            self = Self(rawValue: self.rawValue - 1) ?? Self.allCases.first!
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
