//
//  App.Feature.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import ComposableArchitecture
import NthComposable
import Foundation

extension dimensionsApp {
    @Reducer
    struct Feature {
        @ObservableState
        struct State {
            var usesMetricSystem: Bool
            var sceneLifecycle: SceneLifecycle.State = .init()

            init() {
                @Dependency(\.userDefaults) var userDefaults
                usesMetricSystem = userDefaults.hasShownFirstLaunch
                ? userDefaults.usesMetricSystem
                : Locale.current.measurementSystem == .metric
            }
        }

        enum Action: BindableAction {
            case onLaunch

            case binding(BindingAction<State>)
            case sceneLifecycle(SceneLifecycle.Action)
        }

        var body: some ReducerOf<Self> {
            BindingReducer()
            Scope(state: \.sceneLifecycle, action: \.sceneLifecycle) {
                SceneLifecycle()
            }
            Reduce { state, action in
                switch action {
                case .onLaunch:
                    return .run { send in
                        @Dependency(\.userDefaults) var userDefaults
                        await userDefaults.sethasShownFirstLaunch(true)
                    }
                case .binding, .sceneLifecycle:
                    return .none
                }
            }
        }
    }
}
