//
//  Creature.Understanding.swift
//  keepers-tech-demo
//
//  Created by hung on 1/19/24.
//

import ComposableArchitecture

extension Creature {
    @Reducer
    struct Understanding {
        @Dependency(\.logger) private var logger
        @Dependency(\.audioSession) private var audio
        
        struct State: Equatable {
            @BindingState var listeningToMusic: Bool = false
        }
        
        enum Action: BindableAction {
            case onLoad
            case binding(BindingAction<State>)
        }
        
        var body: some ReducerOf<Self> {
            BindingReducer()
            Reduce { state, action in
                switch action {
                case .onLoad:
                    return .merge(listeningToMusicTask)
                case .binding:
                    doShit(with: state)
                    return .none
                }
            }
        }
        
        private func doShit(with state: borrowing State) {
            let value = state.listeningToMusic
            logger.debug("Listening to music: \(value)")
        }
    }
}

// MARK: Task Effects for onLoad
extension Creature.Understanding {
    fileprivate var listeningToMusicTask: EffectOf<Self> { .run(priority: .utility) { send in
        logger.debug("listening task started")
        for await otherIsPlayingStatus in audio.anotherAppIsPlayingMusicUpdates {
            let listening = switch otherIsPlayingStatus {
            case .begin: true
            case .end: false
            @unknown default: false
            }
            await send(.set(\.$listeningToMusic, listening))
        }
    }}
}
