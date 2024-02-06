//
//  StepBasicView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

import SwiftUI
import ComposableArchitecture

extension demoApp {    
    struct StepBasicView: View {
        typealias Step = demoApp.Step
        @Bindable var store: StoreOf<demoApp.Feature>
        
        @State private var animatedTitle: String = ""
        @State private var isAnimationFinished: Bool = false

        @Environment(\.openImmersiveSpace) var openImmersiveSpace
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
        @Environment(\.openWindow) var openWindow
        @Environment(\.dismissWindow) var dismissWindow
        
        var body: some View {
            NavigationStack {
                if let data = demoApp.stepData[store.step] {
                    Text(.init(data.computeBody(name: store.name)))
                        .font(.title)
                        .opacity(isAnimationFinished ? 1 : 0)
                        .typeText(
                            text: $animatedTitle,
                            finalText: data.title,
                            isFinished: $isAnimationFinished,
                            speed: 30)
                        .navigationTitle(animatedTitle)
                    inlineButtons(store)
                        .opacity(isAnimationFinished ? 1 : 0)
                }
            }
            .animation(isAnimationFinished ? .easeOut(duration: 2) : .none,
                       value: isAnimationFinished)
            .toolbar {
                demoApp.ornamentButtons(store, demoApp.stepData[store.step]?.buttons)
            }
            .padding()
            .frame(idealWidth: 600, idealHeight: 600)
        }
        
        // TODO: Use button options instead
        @MainActor
        private func inlineButtons(
            _ store: StoreOf<demoApp.Feature>
        ) -> some View {
            VStack {
                switch store.step {
                case .heroScreen:
                    EmptyView()
//                case .welcomeAbstract:
//                    EmptyView()
//                case .volumeIntro:
//                    HStack {
//                        nameToggle("Ami")
//                        nameToggle("Meredith")
//                        nameToggle("Olivia")
//                        nameToggle("Benjamin")
//                    }
//                    let text = (store.isVolumeOpen ? "Hide " : "Show ") + store.name
//                    let systemImage = store.isVolumeOpen
//                    ? "circle.dashed.inset.filled"
//                    : "circle.dashed"
//                    let binding = store.binding(get: \.isVolumeOpen, send: { open in
//                        let id = Creature.VolumetricView.ID
//                        return .run(open ? .openWindow(id) : .dismissWindow(id))
//                    })
//                    Toggle(text, systemImage: systemImage, isOn: binding)
//                        .toggleStyle(.button)
//                        .animation(.default, value: store.isVolumeOpen)
//                case .immersiveIntro:
//                    let text = store.isImmersiveSpaceOpen
//                    ? "Hide \(store.name)"
//                    : "Let \(store.name) Roam"
//                    let systemImage = store.isImmersiveSpaceOpen
//                    ? "arrow.down.right.and.arrow.up.left"
//                    : "arrow.up.left.and.arrow.down.right"
//                    let binding = store.binding(get: \.isImmersiveSpaceOpen, send: { open in
//                        let id = Creature.ImmersiveView.ID
//                        // TODO
//                        // await some  some animation transition to remove from window.
//                        // and then add to immersive space, ofc. Technically they can be two different entities, so we can fake
//                        // We should also dismiss/enable window again...
//                        return .run(open ? .openImmersiveSpace(id) : .dismissImmersiveSpace)
//                    })
//                    Button("Random Color") {
//                        let randomColor: SwiftUI.Color = .init(
//                            hue: .random(in: 0...1),
//                            saturation: 1,
//                            brightness: 1)
//                        store.send(.creature(.set(\.$color, .init(randomColor))))
//                    }
//                    Toggle(text, systemImage: systemImage, isOn: binding)
//                        .toggleStyle(.button)
//                        .animation(.default, value: store.isImmersiveSpaceOpen)
//                        .disabled(true)
//                    Text("Due to incomplete developer tools, this feature (using immersive scenes) has been disabled until it can be tested on device.")
//                        .font(.footnote)
//                case .soundAnalyserIntro:
//                    let isUsingSoundAnalysis = store.runOptions?.contains(.soundAnalysis) ?? false
//                    let text = (isUsingSoundAnalysis ? "Disable" : "Enable") + " Listening"
//                    let systemImage = isUsingSoundAnalysis
//                    ? "mic.fill"
//                    : "mic"
//                    let binding = store.binding(get: { state in
//                        state.runOptions?.contains(.soundAnalysis) ?? false
//                    }, send: demoApp.Feature.Action.enableListening)
//                    
//                    Toggle(text, systemImage: systemImage, isOn: binding)
//                        .toggleStyle(.button)
//                        .animation(.default, value: isUsingSoundAnalysis)
//                case .meshClassificationIntro:
//                    let isUsingWorldSensing = !(store.runOptions?.intersection([.meshUpdates, .planeUpdates, .handUpdates]).isEmpty ?? true)
//                    let text = (isUsingWorldSensing ? "Disable" : "Enable") + " Environment Understanding"
//                    let systemImage = isUsingWorldSensing
//                    ? "arkit"
//                    : "arkit.badge.xmark"
//                    let binding = store.binding(get: { state in
//                        !(state.runOptions?.intersection([.meshUpdates, .planeUpdates, .handUpdates]).isEmpty ?? true)
//                    }, send: demoApp.Feature.Action.enableWorldUnderstanding)
//                    
//                    Toggle(text, systemImage: systemImage, isOn: binding)
//                        .toggleStyle(.button)
//                        .animation(.default, value: isUsingWorldSensing)
//                        .disabled(true)
//                    Text("Due to incomplete developer tools, this feature (using immersive scenes) has been disabled until it can be tested on device.")
//                        .font(.footnote)
//                case .futureDevelopment:
//                    EmptyView()
                case .controls:
                    EmptyView()
                case .soundAnalyserOnlyIntro:
                    thresholdSlider()
                    HStack {
                        randomColorButton()
                        enableVolumeToggle(name: "critter")
                    }
                    enableListeningToggle()
                }
            }
        }
        
        private func randomColorButton() -> some View {
            Button("Random Color") {
                let randomColor: SwiftUI.Color = .init(
                    hue: .random(in: 0...1),
                    saturation: 1,
                    brightness: 1)
                store.send(.creature(.set(\.color, .init(randomColor))))
            }
        }
        
        private func thresholdSlider() -> some View {
            let text = "Threshold (\(store.soundAnalysisConfidenceThreshold))"
            let binding = Binding<Double>(
                get: { 1 - store.soundAnalysisConfidenceThreshold },
                set: { store.send(.set(\.soundAnalysisConfidenceThreshold, 1 - $0)) }
            )
            return Slider(value: binding, in: 0...1) {
                Text(.init(text))
            }
            .help("Sensitivity: \(store.soundAnalysisConfidenceThreshold)")

        }
        
        private func enableVolumeToggle(name: String? = .none) -> some View {
            let text = (store.isVolumeOpen ? "Hide " : "Show ") + (name ?? store.name)
            let systemImage = store.isVolumeOpen
            ? "circle.dashed.inset.filled"
            : "circle.dashed"
            
            let binding = Binding<Bool>(
                get: { store.isVolumeOpen },
                set: { open in
                    let id = Creature.VolumetricView.ID
                    open ? openWindow(id: id) : dismissWindow(id: id)
                }
            )
            return Toggle(text, systemImage: systemImage, isOn: binding)
                .toggleStyle(.button)
                .animation(.default, value: store.isVolumeOpen)
        }
        
        private func enableListeningToggle() -> some View {
            let isUsingSoundAnalysis = store.usingSoundAnalysis
            let text = (isUsingSoundAnalysis ? "Disable" : "Enable") + " Listening"
            let systemImage = isUsingSoundAnalysis
            ? "mic.fill"
            : "mic"
            let binding = $store.usingSoundAnalysis.sending(\.enableListening)
            
            return Toggle(text, systemImage: systemImage, isOn: binding)
                .toggleStyle(.button)
                .animation(.default, value: isUsingSoundAnalysis)
        }

        @MainActor
        private func openSettings() async {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
        }
        
        @ViewBuilder
        private func nameToggle(_ name: String) -> some View {
            let binding = Binding<Bool>(
                get: { store.name == name },
                set: { _ in store.send(.creature(.set(\.name, name))) })
            Toggle(isOn: binding) {
                Text(name)
            }
            .toggleStyle(.button)
            .animation(.default, value: store.name)
        }
    }
}
