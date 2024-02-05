//
//  Creature.View.swift
//  keepers-tech-demo
//
//  Created by hung on 1/25/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import ComposableArchitecture

extension Creature {
    struct View: SwiftUI.View {
        @Bindable var store: StoreOf<Creature.Feature>
        
        @State var volumeSize: Size3D?

        var tap: some Gesture {
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { event in
                    store.send(._nextAnimation)
                }
        }
        
        var body: some SwiftUI.View {
            let windowed = volumeSize != .none
            RealityView { content, attachments in
                let creatureMaterial = try? await ShaderGraphMaterial(
                    named: "/Root/CelShading",
                    from: "Materials/CustomMaterials",
                    in: realityKitContentBundle)
                let ent = Creature.Entity(
                    store: store,
                    material: creatureMaterial,
                    windowed: windowed)
                if let size = volumeSize {
                    ent.transform.translation = [0, -Float(size.height / 2), 0]
                }
                content.add(ent)
                
                if let buttonAttachment = attachments.entity(for: TextBubble.ID) {
                    content.add(buttonAttachment)
                    buttonAttachment.components.set(Follow.Component(
                        followeeID: ent.body?.id ?? ent.id,
                        offset: [0, windowed ? 0.095: 0.15, 0],
                        mode: .lazy(1)))
//                    if !windowed {
//                        buttonAttachment.components.set(Billboard.Component(mode: .direct))
//                    }
                }
            } attachments: {
                Attachment(id: TextBubble.ID) {
                    TextBubble(intentText: store.intent.textBubble)
                }
            }
            .gesture(tap)
        }
    }
}

#Preview {
    Creature.View(
        store: Store(initialState: Creature.Feature.State(), reducer: { Creature.Feature() })
    )
}
