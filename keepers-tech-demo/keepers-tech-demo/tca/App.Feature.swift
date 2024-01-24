//
//  App.Feature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

import ComposableArchitecture
import SwiftUI

extension demoApp {
    @Reducer
    struct Feature: Reducer {
        @Dependency(\.logger) var logger
        @Dependency(\.cloudkitManager) var cloudkit
        
        @Environment(\.openImmersiveSpace) var openImmersiveSpace
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
        @Environment(\.openWindow) var openWindow
        @Environment(\.dismissWindow) var dismissWindow
        
        struct State {
            @BindingState var step: Step
            @BindingState var name: String = "Ami"
            @BindingState var creature: Creature.Feature.State? = .none
            
            @BindingState var isVolumeOpen: Bool = false
            @BindingState var isImmersiveSpaceOpen: Bool = false
        }
        
        enum Action: BindableAction {
            case binding(BindingAction<State>)

            case next
            case previous
            case run(EnvironmentAction)
            case vote
            
            case creature(Creature.Feature.Action)
        }
        
        var body: some ReducerOf<Self> {
            BindingReducer()

            Reduce { state, action in
                switch action {
                case .next:
                    state.step.next()
                    return .none
                case .previous:
                    state.step.previous()
                    return .none
                case .run(let environmentAction):
                    return .run { send in
                        switch environmentAction {
                        case .openImmersiveSpace(let id):
                            await openImmersiveSpace(id: id)
                        case .dismissImmersiveSpace:
                            await dismissImmersiveSpace()
                        case .openWindow(let id):
                            openWindow(id: id)
                        case .dismissWindow(let id):
                            dismissWindow(id: id)
                        }
                    }
                case .vote:
                    cloudkit.vote()
                    return .none
                case .creature, .binding:
                    return .none
                }
            }.ifLet(\.creature, action: /Action.creature) {
                Creature.Feature()
            }
        }
        
        enum EnvironmentAction: Equatable {
            case openImmersiveSpace(String)
            case dismissImmersiveSpace
            case openWindow(String)
            case dismissWindow(String)
        }
    }
}

extension demoApp {
    enum Step: Int, CaseIterable, Comparable, Equatable {
        case heroScreen
        case welcomeAbstract
        case volumeIntro
        case immersiveIntro
        case soundAnalyserIntro
        case meshClassificationIntro
        case futureDevelopment
        case controls
        
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
