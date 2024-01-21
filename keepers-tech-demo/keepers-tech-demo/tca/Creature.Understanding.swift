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
                    return .merge(
                        listeningToMusicTask,
                        soundAnalysisTask,
                        meshUpdatesTask,
                        planeUpdatesTask)
                case .binding:
                    doShit(with: &state)
                    return .none
                }
            }
        }
        
        func doShit(with state: inout State) {
        }
    }
}

// MARK: Task Effects for onLoad
extension Creature.Understanding {
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
