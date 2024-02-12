//
//  PlaneMeasureView.swift
//  dimensions
//
//  Created by hung on 2/12/24.
//

import SwiftUI
import ComposableArchitecture
import RealityKit
import RealityKitContent

struct PlaneMeasureView: View {
    @Bindable var store: StoreOf<PlaneMeasure>
    @Binding var usesMetricSystem: Bool

//    let drawPlanesConfig: PlaneVisualization.Configuration = .init(
//        root: Entity(),
//        mesh: .generatePlane(width: 1, height: 1),
//        material: UnlitMaterial(color: .init(white: 1, alpha: 0.01)))

    let drawLinesConfig: PlaneVisualization.Configuration = .init(
        root: Entity(),
        mesh: .generateBox(width: 0.01, height: 1, depth: 0.01, cornerRadius: 0.01),
//        mesh: .generatePlane(width: 0.01, height: 1),
        material: SimpleMaterial())

    var body: some View {
        RealityView { content, attachments in
            content.add(drawLinesConfig.root)
            addAttachments(&content, attachments)
        } update: { content, attachments in
            addAttachments(&content, attachments)
        } attachments: {
            ForEach(Array(store.labels.keys), id: \.self) { key in
                Attachment(id: key) {
                    Text(store.labels[key]!.label(metric: usesMetricSystem))
                        .padding()
                        .glassBackgroundEffect()
                }
            }
        }
        .task {
            store.send(.onStart(await makeDrawLinesConfig()))
        }
        .onDisappear {
            store.send(.onEnd)
        }
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
        for (key, value) in store.labels {
            guard let attachment = attachments.entity(for: key) else { continue }
            attachment.setTransformMatrix(value.transform, relativeTo: .none)
            attachment.components.set(GroundingShadowComponent(castsShadow: true))
//            attachment.components.set(TextSpin.Component(alignment: value.alignment))

            content.add(attachment)
        }
    }
}


#Preview {
    PlaneMeasureView(store: .init(initialState: .init(), reducer: {
        PlaneMeasure()
    }), usesMetricSystem: .constant(true))
    .previewLayout(.sizeThatFits)
}
