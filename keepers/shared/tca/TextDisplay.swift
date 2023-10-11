//
//  TextDisplay.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import SwiftUI
import ComposableArchitecture

struct TextDisplay: Reducer {
    struct State: Equatable {
        var title: String
        var autoscroll: Bool
        var text: LocalizedStringKey
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
