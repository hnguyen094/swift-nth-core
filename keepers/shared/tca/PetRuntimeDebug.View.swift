//
//  PetRuntimeDebug.View.swift
//  keepers
//
//  Created by Hung on 10/10/23.
//

import SwiftUI
import ComposableArchitecture

extension PetRuntimeDebug {
    struct View: SwiftUI.View {
        let store: StoreOf<PetRuntimeDebug>
    }
}

extension PetRuntimeDebug.View {
    var body: some SwiftUI.View {
        WithViewStore(self.store, observe: identity) { viewStore in
            List {
                Section("Commands (sorted)") {
                    ForEach(
                        Array(viewStore.pet.userInputs!.sorted(by: <).enumerated()),
                        id: \.element.persistentModelID)
                    { i, command in
                        HStack {
                            Text(command.timestamp.formatted())
                            Spacer()
                            Text(String.init(describing: command.action))
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete", systemImage: "trash.fill") {
                                store.send(.deleteCommand(IndexSet(arrayLiteral: i)))
                            }
                            .tint(Color.red)
                        }
                    }
                }
            }
            .navigationTitle("Runtime Debug")
            .navigationBarTitleDisplayMode(.inline)
            List {
                Section("Functions") {
                    DatePicker("Date", selection: viewStore.binding(
                        get: \.time,
                        send: { .set(\.$time, $0) }))
                    Picker("Action", selection: viewStore.binding(
                        get: \.action,
                        send: { .set(\.$action, $0)})) {
                            ForEach(Command.Action.allCases, id: \.self) { opt in
                                Text(String.init(describing: opt))
                            }
                        }
                    HStack {
                        Button("Observe") {
                            store.send(.observeButtonTapped)
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button("Submit command") {
                            store.send(.submitNewCommand)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                Section("Observed Result") {
                    if viewStore.runtimeResult != nil {
                        Text("`\(String.init(describing:viewStore.runtimeResult!))`")
                    } else {
                        Text("`N/A`")
                    }
                }
            }
        }
    }
}

#Preview {
    PetRuntimeDebug.View(store: Store(initialState: PetRuntimeDebug.State(pet: PetIdentity.test)) {
        PetRuntimeDebug()
    })
}
