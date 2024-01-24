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
            var runOptions: RunOptions = .all
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
                    let runOptions = state.runOptions
                    let tasks: [EffectOf<Self>] = [
                        intentComputeTask,
                        runOptions.contains(.listenToMusic) ? listeningToMusicTask : .none,
                        runOptions.contains(.soundAnalysis) ? soundAnalysisTask : .none,
                        runOptions.contains(.planeUpdates) ? planeUpdatesTask : .none,
                        runOptions.contains(.meshUpdates) ? meshUpdatesTask : .none,
                        runOptions.contains(.handUpdates) ? handUpdatesTask : .none
                    ].compact()
                    return .merge(tasks)
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
                    .filter { $0.confidence > 0.5 }
                
                let result = confidentResults
                    .compactMap({ SoundAnalyser.soundTypeEmojiMapping[$0.label] })
                    .reduce(into: "") { result, mappedEmoji in
                    result = result + mappedEmoji
                }
//                if let hasMusic = confidentResults.first(where: { $0.label == .music }) {
//                    intent.emotionAnimation = .dance
//                }
                intent.textBubble = result == "" ? .none : result
            }
            return intent
        }
    }
}

// MARK: Run Options
extension Creature.Understanding {
    struct RunOptions: OptionSet {
        let rawValue: Int
        static let listenToMusic = Self(rawValue: 1 << 0)
        static let soundAnalysis = Self(rawValue: 1 << 1)
        static let planeUpdates = Self(rawValue: 1 << 2)
        static let meshUpdates = Self(rawValue: 1 << 3)
        static let handUpdates = Self(rawValue: 1 << 4)
        
        static let all = Self(rawValue: ~0)
    }
}

// MARK: Task Effects for onLoad
extension Creature.Understanding {
    private var intentComputeTask: EffectOf<Self> { .run(priority: .utility) { send in
        while(true) {
            let milliseconds = /*(1 + UInt64.random(in: 0...1)) * */2000
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
            var msg = "\(result.timeRange):\n"
            var wasHigh = true
            for classification in result.classifications {
                if wasHigh && classification.confidence < 0.5 {
                    msg += "\n"
                    wasHigh = false
                }
                let confidence = String(format: "%.2f", classification.confidence)
                msg += "\(confidence): \(classification.label.rawValue)\n"
            }
            logger.debug("\(msg)")
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
    
    private var handUpdatesTask: EffectOf<Self> { .none }
}
