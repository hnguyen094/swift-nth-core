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
            var mode: Mode.State = .meshes(.init())

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
            case mode(Mode.Action)
        }

        @Dependency(\.userDefaults) var userDefaults
        
        var body: some ReducerOf<Self> {
            BindingReducer()
            Scope(state: \.sceneLifecycle, action: \.sceneLifecycle) {
                SceneLifecycle()
            }
            Scope(state: \.mode, action: \.mode) {
                Mode()
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
                case .binding, .sceneLifecycle, .mode:
                    return .none
                }
            }
        }
    }

    @Reducer
    struct Mode {
        @ObservableState
        enum State {
            case planes(PlaneMeasure.State)
            case meshes(MeshMeasure.State)
        }
        enum Action {
            case planes(PlaneMeasure.Action)
            case meshes(MeshMeasure.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.planes, action: \.planes) {
                PlaneMeasure()
            }
            Scope(state: \.meshes, action: \.meshes) {
                MeshMeasure()
            }
        }
    }
}
