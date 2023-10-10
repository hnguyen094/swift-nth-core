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
                state.destination = .petsList(PetList.State())
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
    
    struct Destination: Reducer {
        enum State {
            case petsList(PetList.State)
            case settings(AudioSettings.State)
            case attribution(TextDisplay.State)
        }
        enum Action {
            case petsList(PetList.Action)
            case settings(AudioSettings.Action)
            case attribution(TextDisplay.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.petsList, action: /Action.petsList) {
                PetList()
            }
            Scope(state: /State.settings, action: /Action.settings) {
                AudioSettings()
            }
            Scope(state: /State.attribution, action: /Action.attribution) {
                TextDisplay()
            }
        }
    }
}
