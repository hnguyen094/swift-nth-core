//
//  TextDisplay.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import ComposableArchitecture

struct TextDisplay: Reducer {
    struct State: Equatable {
        var autoscroll: Bool = true
        var title: String
        var text: String
    }
    
    enum Action {}
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        return .none
    }
}
