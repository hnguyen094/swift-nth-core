//
//  AddOrEditPet.View.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import SwiftUI
import ComposableArchitecture

extension AddOrEditPet {
    struct View: SwiftUI.View {
        let store: StoreOf<AddOrEditPet>
    }
}

extension AddOrEditPet.View {
    var body: some SwiftUI.View {
        WithViewStore(self.store, observe: identity) { viewStore in
            List() {
                LabeledContent {
                    if let id = viewStore.state.petIdentity?.persistentModelID.id {
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(String(describing: id))
                                .lineLimit(1)
                        }
                    } else {
                        Text("TBD")
                    }
                } label: {
                    Text("ID")
                }
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
                
                Picker("Species", selection: viewStore.binding(
                    get: \.species,
                    send: { .set(\.$species, $0)})) {
                        ForEach(PetSpecies.allCases, id: \.self) { opt in
                            Text(String.init(describing: opt))
                        }
                    }
                
                Section {
                    createPersonalityAttributeSlider(viewStore: viewStore, keyPath: \.mind)
                    createPersonalityAttributeSlider(viewStore: viewStore, keyPath: \.nature)
                    createPersonalityAttributeSlider(viewStore: viewStore, keyPath: \.energy)
                } header: {
                    Text("Personality traits")
                }
            }
            .navigationTitle("Pet Modifications")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Submit") {
                    store.send(.submit)
                }
            }
        }
        
    }
    
    private func createPersonalityAttributeSlider(
        viewStore: ViewStoreOf<AddOrEditPet>,
        keyPath: WritableKeyPath<PetPersonality, Int8>) 
    -> some SwiftUI.View {
        return LabeledContent {
            Slider(
                value: .convert(from: viewStore.binding(
                    get: { $0.personality[keyPath: keyPath] },
                    send: { .updatePersonality(keyPath, $0) })),
                in: Float(Int8.min)...Float(Int8.max),
                step: 1,
                label: {
                    Text(parseKeyPath(keyPath))
                })
        } label: {
            Text(parseKeyPath(keyPath))
        }
        func parseKeyPath(_ kp: AnyKeyPath) -> String {
            let str = keyPath.debugDescription
            let index = str.index(after: str.lastIndex(of: ".")!)
            return String(str[index...])
        }
    }
}

#Preview {
    AddOrEditPet.View(store: Store(initialState: AddOrEditPet.State()) {
        AddOrEditPet()
    })
}
