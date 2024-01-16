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
        @Dependency(\.modelContext) private var modelContext

        struct State: Equatable { // should mirror Backing
            @BindingState var emotionAnimation: Emoting.Animation = .idle

            // store which classifications is approved, which unknown,(& implicitly which denied)
        }
        
        enum Action: BindableAction {
            case binding(BindingAction<State>)

            case onLoad
            case onBackingReceived(Creature.Backing?)
            
            case _nextAnimation
        }
        
        var body: some ReducerOf<Self> {
            BindingReducer()

            Reduce { state, action in
                switch action {
                case .onLoad:
                    return .run { send in
                        let pet: Creature.Backing? = try await modelContext.fetch().first
                        await send(.onBackingReceived(pet))
                    } catch: { _, _ in
                        fatalError("Failed to load model container context.")
                    }
                case .onBackingReceived(let maybeBacking):
                    // state.blah = maybeBacking.blah
                    return .none
                case ._nextAnimation:
                    let index = Emoting.Animation.allCases.firstIndex(of: state.emotionAnimation)!
                    state.emotionAnimation = Emoting.Animation.allCases[(index + 1) % (Emoting.Animation.allCases.count - 1)]
                    return .none
                case .binding:
                    return .none
                }
            }
        }
    }
}
