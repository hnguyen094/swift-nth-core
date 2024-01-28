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
        let store: StoreOfView
        
        @State private var animatedTitle: String = ""
        @State private var isAnimationFinished: Bool = false
        
        var body: some View {
            WithViewStore(store, observe: { $0 }) { viewStore in
                NavigationStack {
                    if let data = demoApp.stepData[viewStore.step] {
                        Text(.init(data.computeBody(name: viewStore.name)))
                            .font(.title)
                            .opacity(isAnimationFinished ? 1 : 0)
                            .typeText(
                                text: $animatedTitle,
                                finalText: data.title,
                                isFinished: $isAnimationFinished,
                                speed: 30)
                            .navigationTitle(animatedTitle)
                        inlineButtons(viewStore)
                            .opacity(isAnimationFinished ? 1 : 0)
                    }
                }
                .animation(isAnimationFinished ? .easeOut(duration: 2) : .none,
                           value: isAnimationFinished)
                .toolbar {
                    demoApp.ornamentButtons(store, demoApp.stepData[viewStore.step]?.buttons)
                }
                .padding()
            }
            .frame(idealWidth: 600, idealHeight: 600)
        }
        
        // TODO: Use button options instead
        @MainActor
        private func inlineButtons(
            _ viewStore: ViewStoreOfView
        ) -> some View {
            VStack {
                switch viewStore.step {
                case .heroScreen:
                    EmptyView()
//                case .welcomeAbstract:
//                    EmptyView()
//                case .volumeIntro:
//                    HStack {
//                        nameToggle(viewStore, "Ami")
//                        nameToggle(viewStore, "Meredith")
//                        nameToggle(viewStore, "Olivia")
//                        nameToggle(viewStore, "Benjamin")
//                    }
//                    let text = (viewStore.isVolumeOpen ? "Hide " : "Show ") + viewStore.name
//                    let systemImage = viewStore.isVolumeOpen
//                    ? "circle.dashed.inset.filled"
//                    : "circle.dashed"
//                    let binding = viewStore.binding(get: \.isVolumeOpen, send: { open in
//                        let id = Creature.VolumetricView.ID
//                        return .run(open ? .openWindow(id) : .dismissWindow(id))
//                    })
//                    Toggle(text, systemImage: systemImage, isOn: binding)
//                        .toggleStyle(.button)
//                        .animation(.default, value: viewStore.isVolumeOpen)
//                case .immersiveIntro:
//                    let text = viewStore.isImmersiveSpaceOpen
//                    ? "Hide \(viewStore.name)"
//                    : "Let \(viewStore.name) Roam"
//                    let systemImage = viewStore.isImmersiveSpaceOpen
//                    ? "arrow.down.right.and.arrow.up.left"
//                    : "arrow.up.left.and.arrow.down.right"
//                    let binding = viewStore.binding(get: \.isImmersiveSpaceOpen, send: { open in
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
//                        .animation(.default, value: viewStore.isImmersiveSpaceOpen)
//                        .disabled(true)
//                    Text("Due to incomplete developer tools, this feature (using immersive scenes) has been disabled until it can be tested on device.")
//                        .font(.footnote)
//                case .soundAnalyserIntro:
//                    let isUsingSoundAnalysis = viewStore.runOptions?.contains(.soundAnalysis) ?? false
//                    let text = (isUsingSoundAnalysis ? "Disable" : "Enable") + " Listening"
//                    let systemImage = isUsingSoundAnalysis
//                    ? "mic.fill"
//                    : "mic"
//                    let binding = viewStore.binding(get: { state in
//                        state.runOptions?.contains(.soundAnalysis) ?? false
//                    }, send: demoApp.Feature.Action.enableListening)
//                    
//                    Toggle(text, systemImage: systemImage, isOn: binding)
//                        .toggleStyle(.button)
//                        .animation(.default, value: isUsingSoundAnalysis)
//                case .meshClassificationIntro:
//                    let isUsingWorldSensing = !(viewStore.runOptions?.intersection([.meshUpdates, .planeUpdates, .handUpdates]).isEmpty ?? true)
//                    let text = (isUsingWorldSensing ? "Disable" : "Enable") + " Environment Understanding"
//                    let systemImage = isUsingWorldSensing
//                    ? "arkit"
//                    : "arkit.badge.xmark"
//                    let binding = viewStore.binding(get: { state in
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
                    thresholdSlider(viewStore)
                    HStack {
                        randomColorButton(viewStore)
                        enableVolumeToggle(viewStore, name: "critter")
                    }
                    enableListeningToggle(viewStore)
                }
            }
        }
        
        private func randomColorButton(_ viewStore: ViewStoreOfView) -> some View {
            Button("Random Color") {
                let randomColor: SwiftUI.Color = .init(
                    hue: .random(in: 0...1),
                    saturation: 1,
                    brightness: 1)
                store.send(.creature(.set(\.$color, .init(randomColor))))
            }
        }
        
        private func thresholdSlider(_ viewStore: ViewStoreOfView) -> some View {
            let text = "Threshold (\(viewStore.soundAnalysisConfidenceThreshold))"
            let binding = viewStore.binding(
                get: { state in 1 - state.soundAnalysisConfidenceThreshold },
                send: { demoApp.Feature.Action.set(\.$soundAnalysisConfidenceThreshold, 1 - $0) })
            
            return Slider(value: binding, in: 0...1) {
                Text(.init(text))
            }
            .help("Sensitivity: \(viewStore.soundAnalysisConfidenceThreshold)")

        }
        
        private func enableVolumeToggle(_ viewStore: ViewStoreOfView, name: String? = .none) -> some View {
            let text = (viewStore.isVolumeOpen ? "Hide " : "Show ") + (name ?? viewStore.name)
            let systemImage = viewStore.isVolumeOpen
            ? "circle.dashed.inset.filled"
            : "circle.dashed"
            let binding = viewStore.binding(get: \.isVolumeOpen, send: { open in
                let id = Creature.VolumetricView.ID
                return .run(open ? .openWindow(id) : .dismissWindow(id))
            })
            return Toggle(text, systemImage: systemImage, isOn: binding)
                .toggleStyle(.button)
                .animation(.default, value: viewStore.isVolumeOpen)
        }
        
        private func enableListeningToggle(_ viewStore: ViewStoreOfView) -> some View {
            let isUsingSoundAnalysis = viewStore.runOptions?.contains(.soundAnalysis) ?? false
            let text = (isUsingSoundAnalysis ? "Disable" : "Enable") + " Listening"
            let systemImage = isUsingSoundAnalysis
            ? "mic.fill"
            : "mic"
            let binding = viewStore.binding(get: { state in
                state.runOptions?.contains(.soundAnalysis) ?? false
            }, send: demoApp.Feature.Action.enableListening)
            
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
        
        private func nameToggle(
            _ viewStore: ViewStoreOfView,
            _ name: String)
        -> some View {
            Toggle(isOn: viewStore.binding(get: { $0.name == name }, send: .creature(.set(\.$name, name)))) {
                Text(name)
            }
            .toggleStyle(.button)
            .animation(.default, value: viewStore.name)
        }
    }
}
