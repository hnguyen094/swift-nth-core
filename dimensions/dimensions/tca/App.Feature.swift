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
            var planeMeasure: PlaneMeasure.State = .init()
            var worldAnchoring: WorldAnchoring.State = .init()

            init() {
                @Dependency(\.userDefaults) var userDefaults
                @Dependency(\.locale) var locale
                usesMetricSystem = userDefaults.hasShownFirstLaunch
                ? userDefaults.usesMetricSystem
                : locale.measurementSystem == .metric
            }
        }

        enum Action: BindableAction {
            case onLaunch

            case binding(BindingAction<State>)
            case sceneLifecycle(SceneLifecycle.Action)
            case planeMeasure(PlaneMeasure.Action)
            case worldAnchoring(WorldAnchoring.Action)
        }

        @Dependency(\.userDefaults) var userDefaults
        
        var body: some ReducerOf<Self> {
            BindingReducer()
            Scope(state: \.sceneLifecycle, action: \.sceneLifecycle) {
                SceneLifecycle()
            }
            Scope(state: \.planeMeasure, action: \.planeMeasure) {
                PlaneMeasure()
            }
            Scope(state: \.worldAnchoring, action: \.worldAnchoring) {
                WorldAnchoring()
            }
            Reduce { state, action in
                switch action {
                case .onLaunch:
                    return .run { send in
                        await userDefaults.setHasShownFirstLaunch(true)
                    }
                case .binding(\.usesMetricSystem):
                    return .run { [usesMetricSystem = state.usesMetricSystem] _ in
                        await userDefaults.setUsesMetricSystem(usesMetricSystem)
                    }
                case .binding, .sceneLifecycle, .planeMeasure, .worldAnchoring:
                    return .none
                }
            }
        }
    }
}
