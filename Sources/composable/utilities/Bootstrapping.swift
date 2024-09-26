//
//  Bootstrapping.swift
//  keepers-tech-demo
//
//  Created by hung on 2/5/24.
//

import ComposableArchitecture
import OSLog

@Reducer
public struct Bootstrapping<R: Reducer> where R.State: Equatable {
    let bootstrap: () async throws -> Void
    let initialState: () -> R.State
    let reducer: () -> R
    
    public init(
        bootstrap: @escaping () async throws -> Void,
        initialState: @autoclosure @escaping () -> R.State,
        reducer: @escaping () -> R)
    {
        self.bootstrap = bootstrap
        self.initialState = initialState
        self.reducer = reducer
    }
    
    @ObservableState
    public enum State: Equatable {
        case bootstrapping(_ message: String)
        case bootstrapped(R.State)
    }
    
    public enum Action {
        case onLaunch
        case response(Result<Void, Error>)
        case bootstrapped(R.Action)
    }

    public var body: some ReducerOf<Self> {
        Scope(state: \.bootstrapped, action: \.bootstrapped) {
            reducer()
        }
        Reduce { state, action in
            switch action {
            case .onLaunch:
                return .run { send in
                    try await bootstrap()
                    await send(.response(.success))
                } catch: { error, send in
                    await send(.response(.failure(error)))
                }
           case .response(.success(_)):
                state = .bootstrapped(initialState())
                return .none
            case .response(.failure(let error)):
                Logger.app.error("Failed to bootstrap \(R.self): \(error)")
                state = .bootstrapping(error.localizedDescription)
                return .none
            case .bootstrapped:
                return .none
            }
        }
    }
}

public extension Bootstrapping.State {
    static var bootstrapping: Self { .bootstrapping("Loading…") }
}
