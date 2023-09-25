//
//  Root.swift
//  keepers
//
//  Created by Hung on 9/8/23.
//

import ComposableArchitecture
import Foundation // TODO: remove when moving this file reader into dependency

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
                state.destination = .petsList(Pets.State())
                return .none
            case .attributionButtonTapped:
                do {
                    var attributions = try readText(from: resources.attributions)
                    state.destination = .attribution(ScrollableText.State(text: attributions))
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
    
    private func readText(from file: String) throws -> String {
        let path = Bundle.main.path(forResource: file, ofType: "txt")
        if path == nil {
            return "[attributions file not found]"
        }
        return try String.init(contentsOfFile: path!)
    }
    
    struct Destination: Reducer {
        enum State {
            case petsList(Pets.State)
            case settings(AudioSettings.State)
            case attribution(ScrollableText.State)
        }
        enum Action {
            case petsList(Pets.Action)
            case settings(AudioSettings.Action)
            case attribution(ScrollableText.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.petsList, action: /Action.petsList) {
                Pets()
            }
            Scope(state: /State.settings, action: /Action.settings) {
                AudioSettings()
            }
            Scope(state: /State.attribution, action: /Action.attribution) {
                ScrollableText()
            }
        }
    }
}
