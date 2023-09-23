//
//  PetAddOrEditView.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import SwiftUI
import ComposableArchitecture

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
                }
                .navigationTitle("Pet Modifications")
                
                Button("Submit") {
                    viewStore.send(.submit)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    PetAddOrEditView(store: Store(initialState: AddOrEditPet.State()) {
        AddOrEditPet()
    })
}