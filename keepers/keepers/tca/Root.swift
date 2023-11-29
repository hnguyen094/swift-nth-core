//
//  Root.swift
//  keepers
//
//  Created by Hung on 9/8/23.
//

import ComposableArchitecture

// TODO: remove when moving this file reader into dependency
import Foundation
import SwiftUI

@Reducer
struct Root: Reducer {
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
                    let attributions = try readText(from: resources.attributions)
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
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    private func readText(from file: String) throws -> LocalizedStringKey {
        let path = Bundle.main.path(forResource: file, ofType: nil)
        if path == nil {
            return "[attributions file not found]"
        }
        return try LocalizedStringKey(String.init(contentsOfFile: path!))
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
