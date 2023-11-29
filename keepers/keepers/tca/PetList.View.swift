//
//  PetsList.View.swift
//  keepers
//
//  Created by Hung on 9/10/23.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

extension PetsList {
    struct View: SwiftUI.View {
        let store: StoreOf<PetsList>
        @Environment(\.editMode) private var editMode
        
        var body: some SwiftUI.View {
            petList
            .popover(
                store: store.scope(
                    state: \.$destination.addOrEdit,
                    action: \.destination.addOrEdit)
            ) { store in
                NavigationView {
                    AddOrEditPet.View(store: store)
                }
            }
            .navigationDestination(
                store: store.scope(
                    state: \.$destination.viewInAR,
                    action: \.destination.viewInAR),
                destination: PetDisplay.View.init(store:))
            .navigationDestination(
                store: store.scope(
                    state: \.$destination.runtimeDebug,
                    action: \.destination.runtimeDebug),
                destination: PetRuntimeDebug.View.init(store:))
            .onAppear {
                store.send(.requestFetch)
            }
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
        
        var petList: some SwiftUI.View {
            List {
                WithViewStore(self.store, observe: \.pets) { viewStore in
                    ForEach(Array(viewStore.state.enumerated()), id: \.element.persistentModelID)
                    { i, pet in
                        if editMode?.wrappedValue.isEditing == true {
                            Button("Edit `\(pet.name)`'s identity") {
                                store.send(.editPetTapped(i))
                            }
                        } else {
                            Button("\(pet.name) (\(pet.birthDate.approximateElapsedTimeDescription) old)") {
                                store.send(.displayPetTapped(i))
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("View in AR", systemImage: "teddybear.fill") {
                                    store.send(.displayPetTapped(i))
                                }
                                .tint(.accentColor)
                                Button("Delete", systemImage: "trash.fill") {
                                    store.send(.deletePetTapped(IndexSet(arrayLiteral: i)))
                                }
                                .tint(Color.red)
                                Button("Edit", systemImage: "square.and.pencil") {
                                    store.send(.editPetTapped(i))
                                }
                                .tint(Color.secondary)
                                Button("Runtime Debug", systemImage: "ladybug") {
                                    store.send(.runtimeDebugTapped(i))
                                }
                                .tint(Color.secondary)
                            }
                        }
                    }
                }
                .onDelete { store.send(.deletePetTapped($0)) }
            }
        }
    }
}

#Preview {
    PetsList.View(store: Store(initialState: PetsList.State()) {
        PetsList()
    })
}
