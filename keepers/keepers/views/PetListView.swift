//
//  PetsView.swift
//  keepers
//
//  Created by Hung on 9/10/23.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

struct PetListView: View {
    typealias Destination = Pets.Destination

    @Environment(\.editMode) private var editMode
    let store: StoreOf<Pets>
    
    var body: some View {
        List {
            WithViewStore(self.store, observe: \.pets) { viewStore in
                ForEach(Array(viewStore.state.enumerated()), id: \.element.id)
                { i, pet in
                    if editMode?.wrappedValue.isEditing == true {
                        Button("Edit `\(pet.name)`'s identity") {
                            store.send(.editPetTapped(i))
                        }
                    } else {
                        Button("\(pet.name) (\(pet.birthDate.approximateElapsedTimeDescription) old)") {
                            store.send(.displayPetTapped(i))
                        }
                    }
                }
            }
            .onDelete { store.send(.deletePetTapped($0)) }
        }
        .popover(
            store: store.scope(state: \.$destination, action: { .destination($0) }),
            state: /Destination.State.addOrEdit,
            action: Destination.Action.addOrEdit,
            content: PetAddOrEditView.init(store:))
        .navigationDestination(
            store: store.scope(state: \.$destination, action: { .destination($0) }),
            state: /Destination.State.viewInAR,
            action: Destination.Action.viewInAR,
            destination: PetDisplayView.init(store:))
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: { store.send(.addPetTapped) } ) {
                    Label("Add pet", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Pets")
    }
}

#Preview {
    PetListView(store: Store(initialState: Pets.State()) {
        Pets()
    })
}
