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
        @Dependency(\.soundAnalysis) private var soundAnalysis
        
        struct State: Equatable {
            @BindingState var mightBeListeningToMusic: Bool = false // reliably false -- so must be correct when true.
            @BindingState var soundAnalysisResult: SoundAnalysisClient.Result? = .none
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
                    return .merge(listeningToMusicTask, soundAnalysisTask)
                case .binding:
                    doShit(with: state)
                    return .none
                }
            }
        }
        
        private func doShit(with state: borrowing State) {
        }
    }
}

// MARK: Task Effects for onLoad
extension Creature.Understanding {
    fileprivate var listeningToMusicTask: EffectOf<Self> { .run(priority: .utility) { send in
        for await otherIsPlayingStatus in audio.anotherAppIsPlayingMusicUpdates {
            let listening = switch otherIsPlayingStatus {
            case .begin: true
            case .end: false
            @unknown default: false
            }
            await send(.set(\.$mightBeListeningToMusic, listening))
        }
    }}
    
    fileprivate var soundAnalysisTask: EffectOf<Self> { .run(priority: .background) { send in
        for await result in soundAnalysis.classificationUpdates() {
            // TODO: could probably handle some processing here
            for classification in result.classifications {
                logger.debug("\(classification.label.rawValue): \(classification.confidence)")
            }
            await send(.set(\.$soundAnalysisResult, result))
        }
    }}
}
