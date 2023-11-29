//
//  Root.swift
//  keepers-together
//
//  Created by Hung on 11/23/23.
//

import ComposableArchitecture
import SwiftUI

struct Root: Reducer {
    @Dependency(\.fileReader) var fileReader
    @Dependency(\.resources) var resources
    @Dependency(\.logger) var logger
    
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
                    _ = await openImmersiveSpace(id: ImmersiveView.Id)
                }
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
    
    struct Destination: Reducer {
        enum State {
            case immersiveView
            case settings(AudioSettings.State)
            case attribution(TextDisplay.State)
        }
        enum Action {
            case immersiveView
            case settings(AudioSettings.Action)
            case attribution(TextDisplay.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.settings, action: /Action.settings) {
                AudioSettings()
            }
            Scope(state: /State.attribution, action: /Action.attribution) {
                TextDisplay()
            }
        }
    }
}
