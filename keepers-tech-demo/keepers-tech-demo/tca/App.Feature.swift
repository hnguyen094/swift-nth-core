//
//  App.Feature.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

import ComposableArchitecture
import SwiftUI
import AVFoundation

extension demoApp {
    @Reducer
    struct Feature: Reducer {
        @Dependency(\.logger) var logger
        @Dependency(\.cloudkitService) var cloudkit
        @Dependency(\.arkitSessionManager) var arkit
        
        @Environment(\.openImmersiveSpace) var openImmersiveSpace
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
        @Environment(\.openWindow) var openWindow
        @Environment(\.dismissWindow) var dismissWindow
        
        struct State {
            @BindingState var step: Step
            @BindingState var creature: Creature.Feature.State = .init()
            
            @BindingState var isVolumeOpen: Bool = false
            @BindingState var isImmersiveSpaceOpen: Bool = false
            
            @BindingState var voteCount: Int64? = .none
            @BindingState var soundAnalysisConfidenceThreshold: Double = 0.5
        }
        
        enum Action: BindableAction {
            case binding(BindingAction<State>)

            case onLoad
            case next
            case previous
            case run(EnvironmentAction)

            case vote
            case enableListening(Bool)
            case enableWorldUnderstanding(Bool)
            
            case creature(Creature.Feature.Action)
        }
        
        var body: some ReducerOf<Self> {
            BindingReducer()

            Scope(state: \.creature, action: \.creature) {
                Creature.Feature()
            }
            
            Reduce { state, action in
                switch action {
                case .onLoad:
                    return .send(.creature(.onLoad))
                case .next:
                    return .send(.set(\.$step, state.step.next))
                case .previous:
                    return .send(.set(\.$step, state.step.previous))
                case .run(let environmentAction):
                    return .run { send in
                        switch environmentAction {
                        case .openImmersiveSpace(let id):
                            await openImmersiveSpace(id: id)
                        case .dismissImmersiveSpace:
                            await dismissImmersiveSpace()
                        case .openWindow(let id):
                            openWindow(id: id)
                        case .dismissWindow(let id):
                            dismissWindow(id: id)
                        }
                    }
                case .vote:
                    return .run { send in
                        await send(.set(\.$voteCount, try await cloudkit.vote(recordType: "Interest", key: "count")))
                    } catch: { error, send in
                        logger.error("Failed to submit vote: \(error)")
                        await send(.set(\.$voteCount, .none))
                    }
                case .binding(\.$soundAnalysisConfidenceThreshold):
                    guard case .some(let runOptions) = state.creature.understanding?.runOptions else {
                        return .none
                    }
                    return .send(.creature(.runUnderstanding(runOptions, state.soundAnalysisConfidenceThreshold)))
                case .enableListening(let enable):
                    let currentRunOptions = state.creature.understanding?.runOptions ?? .init()
                    let threshold = state.soundAnalysisConfidenceThreshold
                    guard enable else {
                        let runOptions = currentRunOptions.subtracting(.soundAnalysis)
                        switch runOptions.isEmpty {
                        case true: return .send(.creature(.stopUnderstanding))
                        case false: return .send(.creature(.runUnderstanding(runOptions, threshold)))
                        }
                    }
                    return .run { send in
                        switch AVCaptureDevice.authorizationStatus(for: .audio) {
                        case .notDetermined:
                            switch await AVCaptureDevice.requestAccess(for: .audio) {
                            case true: await continueWithAuthorization()
                            case false: await skipWithNoAuthorization()
                            }
                        case .authorized: await continueWithAuthorization()
                        case .denied: await openSettings()
                        case .restricted: await skipWithNoAuthorization()
                        @unknown default: await skipWithNoAuthorization()
                        }
                        
                        func continueWithAuthorization() async {
                            // TODO: run demo too
                            await send(.creature(.runUnderstanding(currentRunOptions.union(.soundAnalysis), threshold)))
                        }
                        
                        func skipWithNoAuthorization() async {
                            logger.error("Cannot get microphone authorization. Skipping.")
                            await send(.next)
                        }
                    }
                case .enableWorldUnderstanding(let enable):
                    let currentRunOptions = state.creature.understanding?.runOptions ?? .init()
                    let relevantRunOptions = Creature.Understanding.RunOptions([.meshUpdates, .planeUpdates, .handUpdates])
                    let threshold = state.soundAnalysisConfidenceThreshold
                    guard enable else {
                        let runOptions = currentRunOptions.subtracting(relevantRunOptions)
                        switch runOptions.isEmpty {
                        case true: return .send(.creature(.stopUnderstanding))
                        case false: return .send(.creature(.runUnderstanding(runOptions, threshold)))
                        }
                    }
                    return .run { send in
                        // request and start whatever we can
                        await arkit.attemptStartARKitSession()
                        let authorization = await arkit.session.queryAuthorization(for: [.worldSensing, .handTracking])
                        let missingAnyAuthorization = authorization[.worldSensing] != .allowed || authorization[.handTracking] != .allowed
                        
                        if missingAnyAuthorization {
                            logger.debug("Missing worldSensing and handTracking authorization.")
                            await openSettings()
                        } else {
                            // TODO: run demo
                            await send(.creature(.runUnderstanding(currentRunOptions.union(relevantRunOptions), threshold)))
                        }
                    }
                case .binding(\.$step):
                    switch state.step {
//                    case .volumeIntro:
//                        return .send(.creature(.set(\.$demoMode, .animations)))
//                    case .immersiveIntro:
//                        return .send(.creature(.set(\.$demoMode, .anchorUnderstanding)))
//                    case .soundAnalyserIntro:
//                        return .send(.creature(.set(\.$demoMode, .soundUnderstanding)))
//                    case .meshClassificationIntro:
//                        return .send(.creature(.set(\.$demoMode, .worldAndHandUnderstanding)))
                    default:
                        return .send(.creature(.set(\.$demoMode, .none)))
                    }
                case .creature, .binding:
                    return .none
                }
            }
        }
        
        @MainActor
        private func openSettings() async {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
        }
        
        enum EnvironmentAction: Equatable {
            case openImmersiveSpace(String)
            case dismissImmersiveSpace
            case openWindow(String)
            case dismissWindow(String)
        }
    }
}

extension demoApp {
    enum Step: Int, CaseIterable, Comparable, Equatable {
        case heroScreen
        case soundAnalyserOnlyIntro
//        case welcomeAbstract
//        case volumeIntro
//        case immersiveIntro
//        case soundAnalyserIntro
//        case meshClassificationIntro
//        case futureDevelopment
        case controls
        
        var next: Self {
            Self(rawValue: self.rawValue + 1) ?? Self.allCases.last!
        }
        
        var previous: Self {
            Self(rawValue: self.rawValue - 1) ?? Self.allCases.first!
        }
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}
