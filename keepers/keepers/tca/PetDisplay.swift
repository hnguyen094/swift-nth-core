//
//  PetDisplay.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import SwiftUI
import ComposableArchitecture
import RealityKit

struct PetDisplay: Reducer {
    @Dependency(\.logger) var logger

    struct State: Equatable {
        var pet: Creature
        var skyboxName: String
    }
    
    enum Action {
        case changeSkybox(String)
        case skyboxError(Error)
        case noop
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .changeSkybox(let skyboxName):
            state.skyboxName = skyboxName
            return .none
        case .skyboxError(let error):
            logger.error("Failed loading skybox. (\(error))")
            return .none
        case .noop:
            return .none
        }
        
    }
    
}
