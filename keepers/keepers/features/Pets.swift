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

typealias PetIdentity = PersistentDataClient.Pet_Identity
typealias PetPersonality = PersistentDataClient.Pet_Personality

struct Pets: Reducer {
    @Dependency(\.modelContainer) var modelContainer
    @Dependency(\.logger) var logger

    struct State: Equatable {
        static func == (lhs: Pets.State, rhs: Pets.State) -> Bool {
            lhs.destination == rhs.destination &&
            lhs.pets.count == rhs.pets.count
        }
        
        @PresentationState var destination: Destination.State?
        var pets: [PetIdentity]
        
        init() {
            @Dependency(\.modelContainer) var modelContainer
            do {
                pets = try ModelContext(modelContainer)
                    .fetch(FetchDescriptor<PetIdentity>())
            } catch {
                fatalError("Failed to load model container context.")
            }
        }
    }
    
    enum Action {
        case addPetTapped
        case editPetTapped(Int)
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination(.dismiss):
                do {
                    logger.debug("fetching updated pets list")
                    state.pets = try ModelContext(modelContainer)
                        .fetch(FetchDescriptor<PetIdentity>())
                } catch {
                    fatalError("Failed to load model container context.")
                }
                return .none
            case .destination:
                return .none
            case .addPetTapped:
                state.destination = .addOrEdit(AddOrEditPet.State())
                return .none
            case .editPetTapped(let index):
                state.destination = .addOrEdit(AddOrEditPet.State(
                    pet: state.pets[index]))
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
        }
        
        enum Action {
            case addOrEdit(AddOrEditPet.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.addOrEdit, action: /Action.addOrEdit) {
                AddOrEditPet()
            }
        }
    }
}

struct AddOrEditPet: Reducer {
    @Dependency(\.modelContainer) var modelContainer
    @Dependency(\.logger) var logger
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        static func == (lhs: AddOrEditPet.State, rhs: AddOrEditPet.State) -> Bool {
            return lhs.name == rhs.name &&
            lhs.personality == rhs.personality &&
            lhs.birthDate == rhs.birthDate && (
                (lhs.petIdentity == nil && rhs.petIdentity == nil) ||
                (lhs.petIdentity != nil && rhs.petIdentity != nil &&
                 lhs.petIdentity!.id == rhs.petIdentity!.id)
            )
        }
        
        var petIdentity: PetIdentity? = nil
        
        @BindingState var name: String = ""
        @BindingState var birthDate: Date = Date()
        var personality: PetPersonality = PetPersonality()
        
        init() {}
        
        init(pet: PetIdentity) {
            petIdentity = pet
            name = pet.name
            birthDate = pet.birthDate
            personality = pet.personality
        }
        
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case updatePersonality(Int8, Int8, Int8)
        case submit
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> {state, action in
            switch action {
            case .binding:
                return .none
            case .updatePersonality(let mind, let nature, let energy):
                state.personality.mind = mind
                state.personality.nature = nature
                state.personality.energy = energy
                return .none
            case .submit:
                logger.debug("in/upsert submitted.")
                let pet = state.petIdentity ?? PetIdentity()
                pet.name = state.name
                pet.personality = state.personality
                pet.birthDate = state.birthDate
                
                let wasUpsert = state.petIdentity != nil
                
                return .run { send in
                    let ctx = ModelContext(modelContainer)
                    ctx.insert(pet)
                    try ctx.save()
                    logger.info("""
                                \(wasUpsert ? "Updated" : "Added") pet \
                                (\(pet.name)) to model container.
                                """)
                    await dismiss()
                } catch: {error, _ in
                    logger.error("Failed to save context. \(error)")
                }
            }
        }
    }
}
