//
//  Bootstrapping.swift
//  keepers-tech-demo
//
//  Created by hung on 2/5/24.
//

import ComposableArchitecture

@Reducer
public struct Bootstrapping<R: Reducer> {
    let bootstrap: () async throws -> Void
    let initialState: R.State
    let reducer: () -> R
    
    public init(
        bootstrap: @escaping () async throws -> Void,
        initialState: @autoclosure () -> R.State,
        reducer: @escaping () -> R)
    {
        self.bootstrap = bootstrap
        self.initialState = initialState()
        self.reducer = reducer
    }
    
    @ObservableState
    public enum State {
        case bootstrapping
        case bootstrapped(R.State)
    }
    
    public enum Action {
        case onLaunch
        case bootstrapResponse(Result<Void, Error>)
        case bootstrapped(R.Action)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onLaunch:
                return .run { send in
                    try await bootstrap()
                    await send(.bootstrapResponse(.success(())))
                } catch: { error, send in
                    await send(.bootstrapResponse(.failure(error)))
                }
           case .bootstrapResponse(.success(_)):
                state = .bootstrapped(initialState)
                return .none
            case .bootstrapResponse(.failure(let error)):
                @Dependency(\.logger) var logger
                logger.error("Failed to bootstrap \(R.self): \(error)")
                return .none
            case .bootstrapped:
                return .none
            }
        }
        Scope(state: \.bootstrapped, action: \.bootstrapped) {
            reducer()
        }
    }
}
