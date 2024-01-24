//
//  StepBasicView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation

extension demoApp {    
    struct StepBasicView: View {
        typealias Step = demoApp.Step
        let store: StoreOfView
        
        @Dependency(\.logger) var logger
        @Dependency(\.arkitSessionManager) var arkitSession
        
        @State private var animatedTitle: String = ""
        @State private var isAnimationFinished: Bool = false
        
        @Environment(\.openImmersiveSpace) var openImmersiveSpace
        @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
        @Environment(\.openWindow) var openWindow
        @Environment(\.dismissWindow) var dismissWindow

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
                case .heroScreen, .welcomeAbstract:
                    EmptyView()
                case .volumeIntro:
                    HStack {
                        nameToggle(viewStore, "Ami")
                        nameToggle(viewStore, "Meredith")
                        nameToggle(viewStore, "Olivia")
                        nameToggle(viewStore, "Benjamin")
                    }
                    let text = (viewStore.isVolumeOpen ? "Hide " : "Show ") + viewStore.name
                    let systemImage = viewStore.isVolumeOpen
                    ? "circle.dashed.inset.filled"
                    : "circle.dashed"
                    let binding = viewStore.binding(get: \.isVolumeOpen, send: { open in
                        let id = Creature.VolumetricView.ID
                        return .run(open ? .openWindow(id) : .dismissWindow(id))
                    })
                    Toggle(text, systemImage: systemImage, isOn: binding)
                        .toggleStyle(.button)
                        .animation(.default, value: viewStore.isVolumeOpen)
                case .immersiveIntro:
                    let text = viewStore.isImmersiveSpaceOpen
                    ? "Hide \(viewStore.name)"
                    : "Let \(viewStore.name) Roam"
                    let systemImage = viewStore.isImmersiveSpaceOpen
                    ? "arrow.down.right.and.arrow.up.left"
                    : "arrow.up.left.and.arrow.down.right"
                    let binding = viewStore.binding(get: \.isImmersiveSpaceOpen, send: { open in
                        let id = Creature.ImmersiveView.ID
                        // TODO
                        // await some  some animation transition to remove from window.
                        // and then add to immersive space, ofc. Technically they can be two different entities, so we can fake
                        // We should also dismiss/enable window again...
                        return .run(open ? .openImmersiveSpace(id) : .dismissImmersiveSpace)
                    })
                    
                    Toggle(text, systemImage: systemImage, isOn: binding)
                        .toggleStyle(.button)
                        .animation(.default, value: viewStore.isImmersiveSpaceOpen)
                case .soundAnalyserIntro:
                    Button("Enable Listening", systemImage: "mic.fill") {
                        Task {
                            switch AVCaptureDevice.authorizationStatus(for: .audio) {
                            case .notDetermined:
                                switch await AVCaptureDevice.requestAccess(for: .audio) {
                                case true: continueWithAuthorization()
                                case false: skipWithNoAuthorization()
                                }
                            case .authorized: continueWithAuthorization()
                            case .denied: await openSettings()
                            case .restricted: skipWithNoAuthorization()
                            @unknown default: skipWithNoAuthorization()
                            }
                            
                            func continueWithAuthorization() {
                                // TODO: run demo too
                                store.send(.creature(.runUnderstanding([.soundAnalysis])))
                            }
                            
                            func skipWithNoAuthorization() {
                                logger.error("Cannot get microphone authorization. Skipping.")
                                store.send(.next)
                            }
                        }
                    }
                case .meshClassificationIntro:
                    Button("Environment Understanding", systemImage: "arkit") {
                        Task {
                            // request and start whatever we can
                            await arkitSession.attemptStartARKitSession()
                            
                            let authorization = await arkitSession.session.queryAuthorization(for: [.worldSensing, .handTracking])
                            let missingAnyAuthorization = authorization[.worldSensing] != .allowed || authorization[.handTracking] != .allowed
                            
                            if missingAnyAuthorization {
                                logger.debug("Missing worldSensing and handTracking authorization.")
                                await openSettings()
                            } else {
                                store.send(.creature(.runUnderstanding([.meshUpdates, .planeUpdates, .handUpdates]))) // TODO: run demo
                            }
                        }
                    }
                case .futureDevelopment, .controls:
                    EmptyView()
                }
            }
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
