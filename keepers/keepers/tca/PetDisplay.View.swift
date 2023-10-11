//
//  PetDisplay.View.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import SwiftUI
import ComposableArchitecture

extension PetDisplay {
    struct View: SwiftUI.View {
        let store: StoreOf<PetDisplay>
    }
}

extension PetDisplay.View {
    var body: some SwiftUI.View {
        WithViewStore(store, observe: identity) { viewStore in
            ZStack {
                VStack {
                    RKView(viewStore: viewStore)
                }
                createOverlay(viewStore)
            }
            .navigationTitle("\(viewStore.pet.name)")
        }
    }
    
    @ViewBuilder
    private func createOverlay(_ viewStore: ViewStoreOf<PetDisplay>) -> some View {
        VStack {
            Text("""
                \(viewStore.pet.birthDate.approximateElapsedTimeDescription) old
                `energy[\(viewStore.pet.personality.energy)]→amplitude`
                """)
            .padding(.all)
            .background(UIColor.systemBackground.color)
            .clipShapeWithStrokeBorder(.capsule, Color.accentColor, style: StrokeStyle(lineWidth: 3))
            .frame(alignment: .center)
            
            Spacer()
            Button {
                // TODO: imagine this pets really hard
            } label: {
                Text("Pet so hard.")
            }
            .buttonStyle(.borderedProminent)
        }
        .font(.title2)
    }
}

//#Preview {
//    @Dependency(\.resources) var resources
//    return PetDisplayView(store: Store(initialState: PetDisplay.State(
//        pet: PetIdentity.test,
//        skyboxName: resources.skybox
//    )) {
//        PetDisplay()
//    })
//}
