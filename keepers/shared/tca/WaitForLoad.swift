//
//  WaitForLoad.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct WaitForLoad: Reducer {
    @Dependency(\.dismiss) var dismiss

    struct State: Equatable {
        var loadingText: LocalizedStringKey
        var task: AnyCancellable?
    }
    
    enum Action {
        case cancelTask
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .cancelTask:
            state.task?.cancel()
            return .run { _ in
                await dismiss()
            }
        }
    }
}
