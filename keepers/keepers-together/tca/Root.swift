//
//  Root.swift
//  keepers-together
//
//  Created by Hung on 11/23/23.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Root: Reducer {
    @Dependency(\.fileReader) var fileReader
    @Dependency(\.resources) var resources
    @Dependency(\.logger) var logger
    
    @Dependency(\.worldTracker) var worldTracker
    
    // TODO: this might not work outside a view. We might need to inject it from the mainApp
    @Environment(\.openImmersiveSpace)
    var openImmersiveSpace: OpenImmersiveSpaceAction
    @Environment(\.dismissImmersiveSpace)
    var dismissImmersiveSpace: DismissImmersiveSpaceAction
    
    struct State {
        @PresentationState var destination: Destination.State?
    }
    
    enum Action {
        case startButtonTapped
        case debugButtonTapped
        case settingsButtonTapped
        case attributionButtonTapped
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination:
                return .none
            case .startButtonTapped:
                // TODO: Implement
                return .run { send in
                    _ = await openImmersiveSpace(id: SampleImmersiveView.Id)
                    await worldTracker.run()
                    await worldTracker.beginMeshAnchorUpdates()
                    await worldTracker.beginPlaneAnchorUpdates()
                    await worldTracker.beginWorldAnchorUpdates()
                }
            case .debugButtonTapped:
                state.destination = .debug(WorldTrackerDebug.State())
                return .none
            case .settingsButtonTapped:
                state.destination = .settings(AudioSettings.State())
                return .none
            case .attributionButtonTapped:
                do {
                    let attributions = try fileReader.readText(resources.attributions)
                    state.destination = .attribution(TextDisplay.State(
                        title: "Attributions",
                        autoscroll: true,
                        text: attributions))
                } catch {
                    logger.error("Failed to read attribution file. (\(error))")
                }
                return .none
            }
        }
    }
    
    @Reducer
    struct Destination: Reducer {
        enum State {
            case immersiveView
            case debug(WorldTrackerDebug.State)
            case settings(AudioSettings.State)
            case attribution(TextDisplay.State)
        }
        enum Action {
            case immersiveView
            case debug(WorldTrackerDebug.Action)
            case settings(AudioSettings.Action)
            case attribution(TextDisplay.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.debug, action: \.debug) {
                WorldTrackerDebug()
            }
            Scope(state: \.settings, action: \.settings) {
                AudioSettings()
            }
            Scope(state: \.attribution, action: \.attribution) {
                TextDisplay()
            }
        }
    }
}
