//
//  Pets.swift
//  keepers
//
//  Created by Hung on 9/10/23.
//

import Foundation
import ComposableArchitecture
import Dependencies
import SwiftData

struct Pets: Reducer {
    @Dependency(\.modelContext) var modelContext
    @Dependency(\.resources) var resources
    @Dependency(\.logger) var logger

    struct State: Equatable {
        static func == (lhs: Pets.State, rhs: Pets.State) -> Bool {
            lhs.destination == rhs.destination &&
            lhs.pets.count == rhs.pets.count
        }
        
        @PresentationState var destination: Destination.State?
        var pets: [PetIdentity] = [PetIdentity]()
    }
    
    enum Action {
        case addPetTapped
        case deletePetTapped(IndexSet)
        case editPetTapped(Int)
        case displayPetTapped(Int)
        case destination(PresentationAction<Destination.Action>)
        
        case requestFetch
        case receiveFetch([PetIdentity])
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination(.dismiss), .requestFetch:
                return .run { send in
                    let pets = try await modelContext
                        .fetch(FetchDescriptor<PetIdentity>())
                    await send(.receiveFetch(pets))
                } catch: { _, _ in
                    fatalError("Failed to load model container context.")
                }
            case .receiveFetch(let pets):
                state.pets = pets
                return .none
            case .destination:
                return .none
            case .addPetTapped:
                state.destination = .addOrEdit(AddOrEditPet.State())
                return .none
            case .deletePetTapped(let indexSet):
                let petsToDelete = indexSet.map({ state.pets[$0] })
                state.pets.remove(atOffsets: indexSet)
                return .run { send in
                    await modelContext.delete(petsToDelete)
                    try await modelContext.save()
                    logger.info("Deleted \(petsToDelete.count) pet(s) from model container.")
                } catch: {error, _ in
                    logger.error("Failed to save context. \(error)")
                }
            case .editPetTapped(let index):
                state.destination = .addOrEdit(AddOrEditPet.State(pet: state.pets[index]))
                return .none
            case .displayPetTapped(let index):
                state.destination = .viewInAR(PetDisplay.State(
                    pet: state.pets[index],
                    skyboxName: resources.skybox))
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case addOrEdit(AddOrEditPet.State)
            case viewInAR(PetDisplay.State)
        }
        
        enum Action {
            case addOrEdit(AddOrEditPet.Action)
            case viewInAR(PetDisplay.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.addOrEdit, action: /Action.addOrEdit) {
                AddOrEditPet()
            }
            Scope(state: /State.viewInAR, action: /Action.viewInAR) {
                PetDisplay()
            }
        }
    }
}
