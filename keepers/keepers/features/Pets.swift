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
    @Dependency(\.modelContextActor) var modelContext
    @Dependency(\.logger) var logger

    struct State: Equatable {
        static func == (lhs: Pets.State, rhs: Pets.State) -> Bool {
            lhs.destination == rhs.destination &&
            lhs.pets.count == rhs.pets.count
        }
        
        @PresentationState var destination: Destination.State?
        var pets: [PetIdentity]
        
        init() {
            @Dependency(\.modelContextActor) var ctx
            do {
                pets = try ModelContext(ctx.modelContainer)
                    .fetch(FetchDescriptor<PetIdentity>())
            } catch {
                fatalError("Failed to load model container context.")
            }
        }
    }
    
    enum Action {
        case addPetTapped
        case deletePetTapped(IndexSet)
        case editPetTapped(Int)
        case destination(PresentationAction<Destination.Action>)
        
        case receiveFetch([PetIdentity])
    }
    
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .destination(.dismiss):
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
    @Dependency(\.modelContextActor) var modelContainer
    @Dependency(\.logger) var logger
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        static func == (
            lhs: AddOrEditPet.State,
            rhs: AddOrEditPet.State) -> Bool {
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
        case updatePersonality(WritableKeyPath<PetPersonality, Int8>, Int8)
        case submit
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> {state, action in
            switch action {
            case .binding:
                return .none
            case .updatePersonality(let keyPath, let value):
                state.personality[keyPath: keyPath] = value
                return .none
            case .submit:
                let pet = state.petIdentity ?? PetIdentity()
                pet.name = state.name
                pet.personality = state.personality
                pet.birthDate = state.birthDate
                
                let wasUpsert = state.petIdentity != nil
                
                return .run { send in
                    await modelContainer.insert([pet])
                    try await modelContainer.save()
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
