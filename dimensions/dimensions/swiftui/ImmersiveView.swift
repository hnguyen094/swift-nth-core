//
//  ImmersiveView.swift
//  dimensions
//
//  Created by hung on 2/6/24.
//

import SwiftUI
import RealityKit
import ComposableArchitecture
import RealityKitContent

struct ImmersiveView: View {
    @Bindable var store: StoreOf<dimensionsApp.Feature>
    
    var planeMeasure: StoreOf<PlaneMeasure> {
        store.scope(state: \.planeMeasure, action: \.planeMeasure)
    }
    
    let drawPlanesConfig: PlaneVisualization.Configuration = .init(
        root: Entity(),
        mesh: .generatePlane(width: 1, height: 1),
        material: UnlitMaterial(color: .init(white: 1, alpha: 0.01)))
    
    let drawLinesConfig: PlaneVisualization.Configuration = .init(
        root: Entity(),
        mesh: .generateCylinder(height: 1, radius: 0.01),
        material: SimpleMaterial())

    var body: some View {
        RealityView { content, attachments in
            content.add(drawPlanesConfig.root)
            content.add(drawLinesConfig.root)
            addAttachments(&content, attachments)
        } update: { content, attachments in
            addAttachments(&content, attachments)
        } attachments: {
            ForEach(Array(planeMeasure.labels.keys), id: \.self) { key in
                Attachment(id: key) {
                    Text(planeMeasure.labels[key]!.label(metric: store.usesMetricSystem))
                        .padding()
                        .glassBackgroundEffect()
                }
            }
        }
        .onAppear {
            planeMeasure.send(.onStart(drawPlanesConfig))
//            let config = await makeDrawLinesConfig()
        }
        .onDisappear { planeMeasure.send(.onEnd) }
    }
    
    func makeDrawLinesConfig() async -> PlaneVisualization.Configuration {
        var copy = drawLinesConfig
        let material = try? await ShaderGraphMaterial(
            named: "/Root/Glow",
            from: "Materials/Glow",
            in: realityKitContentBundle)
        if let glowMaterial = material {
            copy.material = glowMaterial
        }
        return copy
    }
    
    func addAttachments(_ content: inout RealityViewContent, _ attachments: RealityViewAttachments) {
        for (key, value) in planeMeasure.labels {
            guard let attachment = attachments.entity(for: key) else { continue }
            attachment.setTransformMatrix(value.transform, relativeTo: .none)
            attachment.components.set(GroundingShadowComponent(castsShadow: true))
//            attachment.components.set(TextSpin.Component(alignment: value.alignment))

            content.add(attachment)
        }
    }
}

#Preview {
    ImmersiveView(store: .init(initialState: .init(), reducer: {
        dimensionsApp.Feature()
    }))
    .previewLayout(.sizeThatFits)
}
