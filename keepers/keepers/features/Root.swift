//
//  Root.swift
//  keepers
//
//  Created by Hung on 9/8/23.
//

import ComposableArchitecture

struct Root: Reducer {
    struct State {
        @PresentationState var destination: Destination.State?
    }
    
    enum Action {
        case destination(PresentationAction<Destination.Action>)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        return .none
    }
    
    struct Destination: Reducer {
        enum State {
            case settings(AudioSettings.State)
        }
        enum Action {
            case settings(AudioSettings.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.settings, action: /Action.settings) {
                AudioSettings()
            }
        }
    }
}
