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
        struct State {
            var step: Step
            var name: String = "Ami"
            var creature: Creature.Feature.State? = .none
        }
        
        enum Action {
            case next
            case previous
            case skipAll
            
            case enableCreature
            case creature(Creature.Feature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .next:
                    state.step.next()
                    return .none
                case .previous:
                    state.step.previous()
                    return .none
                case .skipAll:
                    state.step = .futureDevelopment
                    return .none
                case .enableCreature:
                    state.creature = .init()
                    return .none
                case .creature:
                    return .none
                }
            }.ifLet(\.creature, action: /Action.creature) {
                Creature.Feature()
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
