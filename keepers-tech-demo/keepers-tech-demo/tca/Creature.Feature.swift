//
//  Creature.Feature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import ComposableArchitecture

import SwiftUI

extension Creature {
    @Reducer
    struct Feature {
        @Dependency(\.modelContext) private var modelContext
        @Dependency(\.logger) private var logger

        struct State: Equatable {
            @BindingState var intent: Intent = .init()
            @BindingState var color: Backing.Color = .clear
            @BindingState var _useCustomMaterial: Bool = true

            var understanding: Understanding.State? = .none

            fileprivate var backing: Backing? = .none
            // store which classifications is approved, which unknown,(& implicitly which denied)
        }
        
        enum Action: BindableAction {
            case binding(BindingAction<State>)
            case understanding(Understanding.Action)

            case onLoad
            case onBackingLoad(Creature.Backing?)

            case runUnderstanding(Understanding.RunOptions)
            case stopUnderstanding
            
            case _nextAnimation
            case _toggleTextBubble(Bool)
            case _changeSquareness(Float)
        }
        
        var body: some ReducerOf<Self> {
            BindingReducer()

            bindingBackingGlue
            
            Reduce { state, action in
                switch action {
                case .onLoad:
                    return loadBacking
                case .onBackingLoad(let backing):
                    state.backing = backing
                    return .none
                case .runUnderstanding(let runOptions):
                    state.understanding = .init(runOptions: runOptions)
                    return .send(.understanding(.onLoad))
                case .stopUnderstanding:
                    state.understanding = .none
                    return .none
                case ._nextAnimation:
                    let index = Emoting.Animation.allCases.firstIndex(of: state.intent.emotionAnimation)!
                    state.intent.emotionAnimation = Emoting.Animation.allCases[(index + 1) % (Emoting.Animation.allCases.count - 1)]
                    return .none
                case ._toggleTextBubble(let shouldShow):
                    state.intent.textBubble = shouldShow
                    ? "Hello World!"
                    : .none
                    return .none
                case ._changeSquareness(let squareness):
                    state.intent.squareness = squareness
                    return .none
                case .understanding(.newIntent(let intent)):
                    return .send(.set(\.$intent, intent))
                case .binding, .understanding:
                    return .none
                }
            }
            .ifLet(\.understanding, action: /Action.understanding) {
                Understanding()
            }
        }
        
        var loadBacking: EffectOf<Self> {
            .run { send in
                var backing: Creature.Backing? = try await modelContext.fetch().first
                if case .none = backing {
                    logger.debug("Didn't find existing backing. Creating & inserting a new one.")
                    let newBacking = Backing()
                    await modelContext.insert([newBacking])
                    backing = newBacking
                }
                await send(.onBackingLoad(backing))
            } catch: { error, _ in
                logger.error("Failed to load model container context. \(error)")
            }
        }
        
        var bindingBackingGlue: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .binding(let bindedAction):
                    switch bindedAction {
                    case \.$color:
                        guard let backing = state.backing else { return .none }
                        backing.color = state.color.toColorData()
                        return .none
                    case \.$intent:
                        return .none
                    default:
                        logger.warning("Missing glue for binding action [\(bindedAction.customDumpDescription)].")
                        return .none
                    }
                case .onBackingLoad(let backing):
                    guard let backing = backing else { return .none }
                    state.color = backing.color.toColor()
                    return .none
                default:
                    return .none
                }
            }
        }
    }
}
