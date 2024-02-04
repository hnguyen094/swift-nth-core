//
//  App.Bootstrap.swift
//  keepers-tech-demo
//
//  Created by hung on 2/3/24.
//
//  See: https://github.com/pointfreeco/swift-composable-architecture/discussions/1528#discussioncomment-3915804

import ComposableArchitecture

extension demoApp {
    @Reducer
    struct Bootstrap: Reducer {
        enum State {
            case bootstrapping
            case bootstrapped(Feature.State)
        }
        
        enum Action {
            case onLaunch
            case bootstrapResponse(success: Bool)
            case bootstrapped(Feature.Action)
        }
        @Dependency(\.logger) var logger
        @Dependency(\.database) var database
        @Dependency(\.audioSession.initialize) var audioSessionInitializer
        @Dependency(\.soundAnalysis.initialize) var soundAnalysisInitializer
        
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .onLaunch:
                    return .run { send in
                        try database.initialize(
                            .local,
                            for: AppSchema.Latest.self,
                            migrationPlan: AppSchema.AppMigrationPlan.self)
                        await database.modelActor()?.enableAutosave()
                        try audioSessionInitializer(.default)
                        try soundAnalysisInitializer(.default)
                        await send(.bootstrapResponse(success: true))
                    } catch: { error, send in
                        await send(.bootstrapResponse(success: false))
                    }
                case .bootstrapResponse(success: true):
                    state = .bootstrapped(Feature.State(step: .heroScreen))
                    return .none
                case .bootstrapResponse(success: false):
                    // TODO: handle error, like retry prompt alert.
                    logger.error("Failed to bootstrap. App will not function correctly.")
                    return .none
                case .bootstrapped:
                    return .none
                }
            }
            Scope(state: \.bootstrapped, action: \.bootstrapped) {
                Feature()
            }
        }
    }
}
