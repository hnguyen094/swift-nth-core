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
        @Dependency(\.arkitSessionManager) private var arkitSession
        
        struct State: Equatable {
            @BindingState var mightBeListeningToMusic: Bool = false
            @BindingState var soundAnalysisResult: SoundAnalyser.Result? = .none
            @BindingState var surfaces: ARKitSessionManager.AvailableSurfaces = .init()
            @BindingState var meshes: ARKitSessionManager.AvailableMeshes = .init()
            
            var dirty: Bool = true
        }
        
        enum Action: BindableAction {
            case onLoad
            case computeIntent
            case newIntent(Intent)
            case binding(BindingAction<State>)
        }
        
        var body: some ReducerOf<Self> {
            BindingReducer()
            Reduce { state, action in
                switch action {
                case .onLoad:
                    return .merge(
                        intentComputeTask,
                        listeningToMusicTask,
                        soundAnalysisTask,
                        meshUpdatesTask,
                        planeUpdatesTask)
                case .computeIntent:
                    if let intent = generateIntent(from: state) {
                        state.dirty = false
                        return .send(.newIntent(intent))
                    }
                    return .none
                case .binding:
                    state.dirty = true
                    return .none
                case .newIntent:
                    return .none
                }
            }
        }
        
        func generateIntent(from state: State) -> Intent? {
            if !state.dirty { return .none }
            var intent = Intent()
            
            if state.mightBeListeningToMusic && audio.anotherAppIsPlayingMusic {
                intent.textBubble = "🎧"
                intent.emotionAnimation = .dance
                return intent
            }

            if let soundAnalysisResult = state.soundAnalysisResult {
                let confidentResults = soundAnalysisResult.classifications
                    .filter { $0.confidence > 0.7 }
                
                let result = confidentResults
                    .compactMap({ SoundAnalyser.soundTypeEmojiMapping[$0.label] })
                    .reduce(into: "") { result, mappedEmoji in
                    result = result + " " + mappedEmoji
                }
                if let hasMusic = confidentResults.first(where: { $0.label == .music }) {
                    intent.emotionAnimation = .dance
                }
                intent.textBubble = result == "" ? .none : result
            }
            return intent
        }
    }
}

// MARK: Task Effects for onLoad
extension Creature.Understanding {
    private var intentComputeTask: EffectOf<Self> { .run(priority: .utility) { send in
        while(true) {
            let milliseconds = (1 + UInt64.random(in: 0...1)) * 3000
            try await Task.sleep(for: .milliseconds(milliseconds))
            await send(.computeIntent)
        }
    }}
    
    private var listeningToMusicTask: EffectOf<Self> { .run(priority: .utility) { send in
        for await otherIsPlayingStatus in audio.anotherAppIsPlayingMusicUpdates {
            let listening = switch otherIsPlayingStatus {
            case .begin: true
            case .end: false
            @unknown default: false
            }
            await send(.set(\.$mightBeListeningToMusic, listening))
        }
    }}

    private var soundAnalysisTask: EffectOf<Self> { .run(priority: .background) { send in
        for await result in soundAnalysis.classificationUpdates() {
            // TODO: could probably handle some processing here
            await send(.set(\.$soundAnalysisResult, result))
        }
    }}
    
    private var planeUpdatesTask: EffectOf<Self> { .run(priority: .background) { send in
        guard let planeData = await arkitSession.planeData else { return }
        var classifications: ARKitSessionManager.AvailableSurfaces = .init()
        for await update in planeData.anchorUpdates {
            classifications.handleUpdate(update)
            await send(.set(\.$surfaces, classifications))
        }
    }}

    private var meshUpdatesTask: EffectOf<Self> { .run(priority: .background) { send in
        guard let sceneReconstructionData = await arkitSession.sceneReconstructionData
        else { return }
        var classifications: ARKitSessionManager.AvailableMeshes = .init()
        for await update in sceneReconstructionData.anchorUpdates {
            classifications.handleUpdate(update)
            await send(.set(\.$meshes, classifications))
        }
    }}
}
