//
//  App.Feature.ViewState.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import Foundation
import ComposableArchitecture

extension demoApp {
    typealias StoreOfView = Store<demoApp.ViewState, demoApp.Feature.Action>
    typealias ViewStoreOfView = ViewStore<demoApp.ViewState, demoApp.Feature.Action>
    
    struct ViewState: Equatable {
        var step: Step
        var name: String
        var isVolumeOpen: Bool
        var isImmersiveSpaceOpen: Bool
        var voteCount: Int64? = .none

        init(state: demoApp.Feature.State) {
            step = state.step
            name = state.creature.name

            isVolumeOpen = state.isVolumeOpen
            isImmersiveSpaceOpen = state.isImmersiveSpaceOpen
            voteCount = state.voteCount
        }
    }
}

extension demoApp.Feature.State {
    var viewState: demoApp.ViewState { .init(state: self) }
}
