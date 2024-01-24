//
//  App.Feature.ViewState.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import Foundation

extension demoApp {
    struct ViewState: Equatable {
        var step: Step
        var name: String
        var showCreature: Bool
        var isVolumeOpen: Bool
        var isImmersiveSpaceOpen: Bool
        var voteCount: Int64? = .none

        init(state: demoApp.Feature.State) {
            step = state.step
            name = state.name
            if case .none = state.creature {
                showCreature = false
            } else {
                showCreature = true
            }
            isVolumeOpen = state.isVolumeOpen
            isImmersiveSpaceOpen = state.isImmersiveSpaceOpen
            voteCount = state.voteCount
        }
    }
}

extension demoApp.Feature.State {
    var viewState: demoApp.ViewState { .init(state: self) }
}
