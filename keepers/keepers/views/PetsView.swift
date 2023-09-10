//
//  PetsView.swift
//  keepers
//
//  Created by Hung on 9/10/23.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

struct PetsView: View {
    typealias Destination = Pets.Destination
    let store: StoreOf<Pets>
    
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: \.pets) { viewStore in
                List {
                    ForEach(Array(viewStore.state.enumerated()), id: \.element.id) {i, pet in
                        Button("Edit \(pet.name)") {
                            store.send(.editPetTapped(i))
                        }
                    }
                }
                .navigationTitle("Pets")
                .popover(
                    store: store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /Destination.State.addOrEdit,
                    action: Destination.Action.addOrEdit
                ) { store in
                    PetAddOrEditView(store: store)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { store.send(.addPetTapped) } ) {
                            Label("Add pet", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
}

struct PetAddOrEditView: View {
    let store: StoreOf<AddOrEditPet>
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: identity) { viewStore in
                TextField(text: viewStore.binding(
                    get: \.name,
                    send: { .set(\.$name, $0) }), prompt: Text("potato")) {
                        Text("Name")
                    }
                
                DatePicker("Birth Date", selection: viewStore.binding(
                    get: \.birthDate,
                    send: { .set(\.$birthDate, $0) }))
                
                Stepper(value: viewStore.binding(
                    get: \.personality.mind,
                    send: { .updatePersonality(
                        $0,
                        viewStore.personality.nature,
                        viewStore.personality.energy) })) {
                            Text("\(viewStore.personality.mind)")
                        }
                Stepper(value: viewStore.binding(
                    get: \.personality.nature,
                    send: { .updatePersonality(
                        viewStore.personality.mind,
                        $0,
                        viewStore.personality.energy) })) {
                            Text("\(viewStore.personality.nature)")
                        }
                Stepper(value: viewStore.binding(
                    get: \.personality.energy,
                    send: { .updatePersonality(
                        viewStore.personality.mind,
                        viewStore.personality.nature,
                        $0) })) {
                            Text("\(viewStore.personality.energy)")
                        }
                Button("Submit") {
                    viewStore.send(.submit)
                }

            }
        }
    }
}

#Preview {
    PetsView(store: Store(initialState: Pets.State()) {
        Pets()
    })
}
