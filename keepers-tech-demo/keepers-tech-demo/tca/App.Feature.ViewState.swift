//
//  App.Feature.ViewState.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import Foundation

extension keepers_tech_demoApp {
    struct ViewState: Equatable {
        var step: Step
        var name: String
        var showCreature: Bool
        
        init(state: keepers_tech_demoApp.Feature.State) {
            step = state.step
            name = state.name
            if case .none = state.creature {
                showCreature = false
            } else {
                showCreature = true
            }
        }
    }
}

extension keepers_tech_demoApp.Feature.State {
    var viewState: keepers_tech_demoApp.ViewState { .init(state: self) }
}
