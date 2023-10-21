//
//  PetList.View.swift
//  keepers
//
//  Created by Hung on 9/10/23.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

extension PetList {
    struct View: SwiftUI.View {
        let store: StoreOf<PetList>
        @Environment(\.editMode) private var editMode
        
        var body: some SwiftUI.View {
            petList
            .popover(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Destination.State.addOrEdit,
                action: Destination.Action.addOrEdit,
                content: { store in
                    NavigationView {
                        AddOrEditPet.View(store: store)
                    }
                })
            .navigationDestination(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Destination.State.viewInAR,
                action: Destination.Action.viewInAR,
                destination: PetDisplay.View.init(store:))
            .navigationDestination(
                store: store.scope(state: \.$destination, action: { .destination($0) }),
                state: /Destination.State.runtimeDebug,
                action: Destination.Action.runtimeDebug,
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
    PetList.View(store: Store(initialState: PetList.State()) {
        PetList()
    })
}
