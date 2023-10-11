//
//  PetRuntimeDebug.swift
//  keepers
//
//  Created by Hung on 10/10/23.
//

import Foundation
import ComposableArchitecture

struct PetRuntimeDebug: Reducer {
    @Dependency(\.modelContext) var modelContext
    @Dependency(\.logger) var logger

    @Dependency(\.petRuntime) var petRuntime
    @Dependency(\.date) var date
    
    struct State: Equatable {
        var pet: Creature
        var expandedItem: Int? = nil
        var runtimeResult: PetRuntime.RuntimeState? = nil
        
        @BindingState var time: Date = .now
        @BindingState var action: Record.Action = .noop
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case observeButtonTapped
        case showObserveResult(PetRuntime.RuntimeState)
        case deleteCommand(IndexSet)
        case submitNewCommand
    }
    
    var body: some ReducerOf<Self> {
            BindingReducer()
        Reduce<State, Action> {state, action in
            switch action {
            case .binding:
                return .none
            case .onAppear:
                state.time = date.now
                return .none
            case .observeButtonTapped:
                return .run { [pet = state.pet, time = state.time] send in
                    let result = petRuntime.observeRuntime(pet, time)
                    await send(.showObserveResult(result))
                }
            case .showObserveResult(let result):
                state.runtimeResult = result
                return .none
            case .deleteCommand(let indexSet):
                var sortedCommands = state.pet.records!.sorted(by: <)
                sortedCommands.remove(atOffsets: indexSet)
                state.pet.records = sortedCommands
                return .run { _ in
                    try await modelContext.save()
                } catch: { error, send in
                    logger.error("Failed to save data. (\(error))")
                }
            case .submitNewCommand:
                petRuntime.modify(state.pet, state.action, state.time)
                return .run { _ in
                    try await modelContext.save()
                } catch: { error, send in
                    logger.error("Failed to save data. (\(error))")
                }
            }
        }
    }
}
