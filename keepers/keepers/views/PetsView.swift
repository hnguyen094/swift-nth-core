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
            List {
                WithViewStore(self.store, observe: \.pets) { viewStore in
                    ForEach(Array(viewStore.state.enumerated()), id: \.element.id)
                    { i, pet in
                        Button("\(pet.name) (\(pet.birthDate.elapsedTimeDescription) old)") {
                            store.send(.editPetTapped(i))
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
        }
    }
}

struct PetAddOrEditView: View {
    let store: StoreOf<AddOrEditPet>
    
    private func createPersonalityAttributeSlider(
        viewStore: ViewStoreOf<AddOrEditPet>,
        keyPath: WritableKeyPath<PetPersonality, Int8>) -> some View {
            return LabeledContent {
                Slider(
                    value: .convert(from: viewStore.binding(
                        get: { $0.personality[keyPath: keyPath] },
                        send: { .updatePersonality(keyPath, $0) })),
                    in: Float(Int8.min)...Float(Int8.max),
                    step: 1,
                    label: {
                        Text("\(String(describing: keyPath))")
                    })
            } label: {
                Text("\(String(describing: keyPath.customDumpDescription))")
            }
            
    }
    
    var body: some View {
        NavigationStack {
            WithViewStore(self.store, observe: identity) { viewStore in
                List() {
                    LabeledContent {
                        TextField("Name",
                            text: viewStore.binding(get: \.name, send: { .set(\.$name, $0) }),
                            prompt: Text("Add a pet name"))
                    } label: {
                        Text("Name")
                    }
                    .multilineTextAlignment(.trailing)
                    
                    DatePicker("Birth Date", selection: viewStore.binding(
                        get: \.birthDate,
                        send: { .set(\.$birthDate, $0) }))
                    
                    Section {
                        createPersonalityAttributeSlider(viewStore: viewStore, keyPath: \.mind)
                        createPersonalityAttributeSlider(viewStore: viewStore, keyPath: \.nature)
                        createPersonalityAttributeSlider(viewStore: viewStore, keyPath: \.energy)
                    } header: {
                        Text("Personality traits")
                    }
                    Button("Submit") {
                        viewStore.send(.submit)
                    }
                }
                .navigationTitle("Pet Modifications")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    PetsView(store: Store(initialState: Pets.State()) {
        Pets()
    })
}
