//
//  AddOrEditPet.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import Foundation
import ComposableArchitecture

struct AddOrEditPet: Reducer {
    @Dependency(\.modelContextActor) var modelContainer
    @Dependency(\.logger) var logger
    @Dependency(\.dismiss) var dismiss
    
    // used in generatePet, probably should be moved out
    @Dependency(\.uuid) var uuid
    @Dependency(\.date) var date
    
    struct State: Equatable {
        var petIdentity: PetIdentity? = nil
        
        @BindingState var name: String = ""
        @BindingState var birthDate: Date = Date()
        @BindingState var species: PetSpecies = .missingno
        var personality: PetPersonality = PetPersonality()
        
        init() {}
        
        init(pet: PetIdentity) {
            petIdentity = pet
            name = pet.name
            birthDate = pet.birthDate
            personality = pet.personality
            species = pet.species
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
                let pet = state.petIdentity ?? generatePet()
                pet.name = state.name
                pet.personality = state.personality
                pet.birthDate = state.birthDate
                pet.species = state.species
                
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
    
    func generatePet() -> PetIdentity {
        let pet = PetIdentity()
        pet.name = "\(Int.random(in: 1..<1000))"
        return pet
    }
}
