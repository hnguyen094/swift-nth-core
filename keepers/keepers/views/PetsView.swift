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
    @Environment(\.editMode) private var editMode

    typealias Destination = Pets.Destination
    let store: StoreOf<Pets>
    
    var body: some View {
        NavigationStack {
            List {
                WithViewStore(self.store, observe: \.pets) { viewStore in
                    ForEach(Array(viewStore.state.enumerated()), id: \.element.id)
                    { i, pet in
                        if editMode?.wrappedValue.isEditing == true {
                            Button("Edit \(pet.name)") {
                                store.send(.editPetTapped(i))
                            }
                        } else {
                            Button("\(pet.name) (\(pet.birthDate.elapsedTimeDescription) old)") {
                                store.send(.displayPetTapped(i))
                            }
                        }
                    }
                }
                .onDelete { store.send(.deletePetTapped($0)) }
            }
            .navigationTitle("Edit Pets")
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
            .popover(
                store: store.scope(
                    state: \.$destination,
                    action: { .destination($0) }),
                state: /Destination.State.addOrEdit,
                action: Destination.Action.addOrEdit,
                content: PetAddOrEditView.init(store:))
            .popover(
                store: store.scope(
                    state: \.$destination,
                    action: { .destination($0) }),
                state: /Destination.State.viewInAR,
                action: Destination.Action.viewInAR,
                content: PetDisplayView.init(store:))
        }
    }
}

#Preview {
    PetsView(store: Store(initialState: Pets.State()) {
        Pets()
    })
}
