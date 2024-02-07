//
//  Root.swift
//  keepers
//
//  Created by Hung on 9/8/23.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Root: Reducer {
    @Dependency(\.fileReader) var fileReader
    @Dependency(\.resources) var resources
    @Dependency(\.logger) var logger

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
            case .settingsButtonTapped:
                state.destination = .settings(AudioSettings.State())
                return .none
            case .startButtonTapped:
                state.destination = .petsList(PetsList.State())
                return .none
            case .attributionButtonTapped:
                do {
                    let attributions = try fileReader.readText(resources.attributions)
                    state.destination = .attribution(TextDisplay.State(
                        title: "Attributions",
                        autoscroll: true,
                        text: LocalizedStringKey(attributions)))
                } catch {
                    logger.error("Failed to read attribution file. (\(error))")
                }
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
    
    @Reducer
    struct Destination: Reducer {
        enum State {
            case petsList(PetsList.State)
            case settings(AudioSettings.State)
            case attribution(TextDisplay.State)
        }
        enum Action {
            case petsList(PetsList.Action)
            case settings(AudioSettings.Action)
            case attribution(TextDisplay.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.petsList, action: \.petsList) {
                PetsList()
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
