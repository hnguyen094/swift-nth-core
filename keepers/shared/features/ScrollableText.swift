//
//  ScrollableText.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import ComposableArchitecture

struct ScrollableText: Reducer {
    struct State {
        var autoscroll: Bool = true
        var text: String
    }
    
    enum Action {
        case cancelAutoscroll
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .cancelAutoscroll:
            state.autoscroll = false
            return .none
        }
    }
}
