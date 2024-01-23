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
        let store: Store<demoApp.ViewState, demoApp.Feature.Action>
        
        @Dependency(\.logger) var logger
        
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
                        Text(data.computeBody(name: viewStore.name))
                            .font(.title)
                            .opacity(isAnimationFinished ? 1 : 0)
                            .typeText(
                                text: $animatedTitle,
                                finalText: data.title,
                                isFinished: $isAnimationFinished,
                                speed: 30)
                            .navigationTitle(animatedTitle)
                        if case .volumeIntro = viewStore.step {
                            HStack {
                                nameToggle(viewStore, "Ami")
                                nameToggle(viewStore, "Meredith")
                                nameToggle(viewStore, "Olivia")
                                nameToggle(viewStore, "Benjamin")
                            }
                            .opacity(isAnimationFinished ? 1 : 0)
                        }
                    }
                }
                .animation(isAnimationFinished ? .easeOut(duration: 2) : .none,
                           value: isAnimationFinished)
                .toolbar {
                    demoApp.ornamentButtons(store, demoApp.stepData[viewStore.step]?.buttons)
                }
                .onChange(of: isAnimationFinished) {_, animationFinished in
                    guard animationFinished else { return }
                    Task {
                        try? await Task.sleep(for: .seconds(5)) // give a chance to read

                        switch viewStore.step {
                        case .volumeIntro:
                            if !viewStore.showCreature {
                                await store.send(.set(\.$creature, .init())).finish()
                            }
                            if !viewStore.isVolumeOpen && !viewStore.isImmersiveSpaceOpen {
                                openWindow(id: Creature.VolumetricView.ID)
                            }
                        case .immersiveIntro:
                            if !viewStore.showCreature {
                                await store.send(.set(\.$creature, .init())).finish()
                            }
                            guard !viewStore.isImmersiveSpaceOpen else { break }
                            let result = await openImmersiveSpace(id: Creature.ImmersiveView.ID)
                            if case .opened = result, viewStore.isVolumeOpen {
                                // TODO
                                // await some  some animation transition to remove from window.
                                // and then add to immersive space, ofc. Technically they can be two different entities, so we can fake
                                dismissWindow(id: Creature.VolumetricView.ID)
                            }
                        default:
                            break
                        }
                    }
                    
                }
                .padding()
            }
            .frame(idealWidth: 600, idealHeight: 600)
        }

        private func nameToggle(_ viewStore: ViewStore<demoApp.ViewState, demoApp.Feature.Action>, _ name: String) -> some View {
            Toggle(isOn: viewStore.binding(get: { $0.name == name }, send: .set(\.$name, name))) {
                Text(name)
            }
            .toggleStyle(.button)
        }
    }
}
