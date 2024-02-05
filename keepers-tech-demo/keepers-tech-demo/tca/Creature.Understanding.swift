//
//  Creature.Understanding.swift
//  keepers-tech-demo
//
//  Created by hung on 1/19/24.
//

import ComposableArchitecture
import NthComposable

extension Creature {
    @Reducer
    struct Understanding {
        @Dependency(\.logger) private var logger

        @Dependency(\.audioSession) private var audio
        @Dependency(\.soundAnalysis) private var soundAnalysis
        @Dependency(\.arkitSessionManager) private var arkitSession
        
        @ObservableState
        struct State: Equatable {
            var mightBeListeningToMusic: Bool = false
            var soundAnalysisResult: SoundAnalyser.Result? = .none
            var surfaces: ARKitSessionManager.AvailableSurfaces = .init()
            var meshes: ARKitSessionManager.AvailableMeshes = .init()
            var indexFingers: ARKitSessionManager.IndexFingersLocations = .init()
            
            var dirty: Bool = true
            var runOptions: RunOptions = .all
            var demo: Demo.Mode? = .none
            var confidenceThreshold: Double = 0.5
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
            if case .some(_) = state.demo {
                return generateDemoIntent(from: state)
            }
            var intent = Intent()
            
//            if state.mightBeListeningToMusic && audio.anotherAppIsPlayingMusic {
//                intent.textBubble = "🎧"
//                intent.emotionAnimation = .dance
//                return intent
//            }

            if let soundAnalysisResult = state.soundAnalysisResult {
                let texts: [String] = soundAnalysisResult.classifications.compactMap { classification in
                    guard classification.confidence > state.confidenceThreshold else { return .none }
                    return classification.label.rawValue.replacingOccurrences(of: "_", with: " ") + " "
                    + (SoundAnalyser.soundTypeEmojiMapping[classification.label] ?? "") + String.init(repeating: "?", count: Int((1-classification.confidence) / 0.2))
                }
                
                let result = String(texts.reduce("") { partialResult, value in
                    "\(partialResult)\(value)\n"
                }.dropLast())

//                let result: String? = if let highConfidence = soundAnalysisResult.classifications.first {
//                    "👂… " + highConfidence.label.rawValue.replacingOccurrences(of: "_", with: " ") + " "
//                    + (SoundAnalyser.soundTypeEmojiMapping[highConfidence.label] ?? "") + String.init(repeating: "?", count: Int((1-highConfidence.confidence) / 0.2))
//                } else {
//                    .none
//                }
                
//                if let hasMusic = confidentResults.first(where: { $0.label == .music }) {
//                    intent.emotionAnimation = .dance
//                }
                intent.textBubble = result == "" ? .none : result
            }
            return intent
        }
        
        func generateDemoIntent(from state: State) -> Intent? {
            switch state.demo {
            case .animations:
                return .none
            case .anchorUnderstanding:
                return .none
            case .soundUnderstanding:
                let text = generateSoundAnalysisText(state.soundAnalysisResult)
                let confidence = state.soundAnalysisResult?.classifications.first?.confidence
                let animation = switch confidence {
                case .some(let valid):
                    switch valid {
                    case 0..<0.5: Emoting.Animation.curiousHeadTilt
                    case 0.5..<0.8: Emoting.Animation.doubleNod
                    default: Emoting.Animation.excitedBounce
                    }
                case .none: Emoting.Animation.headShake
                }
                return .init(emotionAnimation: animation, textBubble: text)
            case .worldAndHandUnderstanding:
                return .none
            case .none:
                return .none
            }
        }
        
        func generateSoundAnalysisText(_ soundResult: SoundAnalyser.Result?) -> String? {
            guard let result = soundResult else { return .none }
            let text: String? = if let highConfidence = result.classifications.first {
                "👂… " + highConfidence.label.rawValue.replacingOccurrences(of: "_", with: " ") + " "
                + (SoundAnalyser.soundTypeEmojiMapping[highConfidence.label] ?? "") + String.init(repeating: "?", count: Int((1-highConfidence.confidence) / 0.2))
            } else {
                .none
            }
            return text == "" ? .none : text
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
    private var intentComputeTask: EffectOf<Self> { .run { send in
        while(true) {
            let milliseconds = /*(1 + UInt64.random(in: 0...1)) * */4000
            try await Task.sleep(for: .milliseconds(milliseconds))
            await send(.computeIntent)
        }
    }}
    
    private var listeningToMusicTask: EffectOf<Self> { .run { send in
        for await otherIsPlayingStatus in audio.anotherAppIsPlayingMusicUpdates {
            let listening = switch otherIsPlayingStatus {
            case .begin: true
            case .end: false
            @unknown default: false
            }
            await send(.set(\.mightBeListeningToMusic, listening))
        }
    }}

    private var soundAnalysisTask: EffectOf<Self> { .run { send in
        for await requestResult in soundAnalysis.classificationUpdates() {
            switch requestResult {
            case .result(let result):
                logger.debug("\(result.debugDescription)")
                await send(.set(\.soundAnalysisResult, result))
            case .error(let error):
                logger.error("Received error: \(error)")
            }
        }
    }}
    
    private var planeUpdatesTask: EffectOf<Self> { .run(priority: .background) { send in
        guard let planeData = await arkitSession.planeData else { return }
        var classifications: ARKitSessionManager.AvailableSurfaces = .init()
        for await update in planeData.anchorUpdates {
            classifications.handleUpdate(update)
            await send(.set(\.surfaces, classifications))
        }
    }}

    private var meshUpdatesTask: EffectOf<Self> { .run(priority: .background) { send in
        guard let sceneReconstructionData = await arkitSession.sceneReconstructionData
        else { return }
        var classifications: ARKitSessionManager.AvailableMeshes = .init()
        for await update in sceneReconstructionData.anchorUpdates {
            classifications.handleUpdate(update)
            await send(.set(\.meshes, classifications))
        }
    }}
    
    private var handUpdatesTask: EffectOf<Self> { .run(priority: .background) { send in
        guard let handData = await arkitSession.handData else { return }
        var indexLocations: ARKitSessionManager.IndexFingersLocations = .init()
        for await update in handData.anchorUpdates {
            indexLocations.handleUpdate(update)
            await send(.set(\.indexFingers, indexLocations))
        }
    }}
}
