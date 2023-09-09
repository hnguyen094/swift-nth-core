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
        case settingsButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination:
                return .none
            case .settingsButtonTapped:
                state.destination = .settings(AudioSettings.State())
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
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
