//
//  StepView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/22/24.
//

import SwiftUI
import ComposableArchitecture

struct Step_HeroScreen: View {
    typealias Step = keepers_tech_demoApp.Step
    let store: StoreOf<keepers_tech_demoApp.Feature>

    @State private var text: String = ""
    @State private var isFinished: Bool = false
    
    private static let subtitleText = "tech demo"
    
    private var subtitle: some View {
        Text(Self.subtitleText)
            .font(.extraLargeTitle2)
    }
    
    var body: some View {
        VStack {
            Text("my ami")
                .font(.extraLargeTitle)
            Text(Self.subtitleText)
                .font(.extraLargeTitle2)
                .monospaced()
                .hidden()
                .overlay(alignment: .leading) {
                    Text(text)
                        .font(.extraLargeTitle2)
                        .typeText(
                            text: $text,
                            finalText: Self.subtitleText,
                            isFinished: $isFinished)
                        .monospaced()
                }
                .onChange(of: isFinished) {
                    Task {
                        try? await Task.sleep(for: .milliseconds(400))
                        store.send(.next)
                    }
                }
        }
        .frame(width: 800, height: 600)
    }
}

struct StepView: View {
    typealias Step = keepers_tech_demoApp.Step
    let store: Store<keepers_tech_demoApp.ViewState, keepers_tech_demoApp.Feature.Action>
    
    @Dependency(\.logger) var logger
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    @State private var animatedTitle: String = ""
    @State private var isAnimationFinished: Bool = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                if let data = Self.stepData[viewStore.step] {
                    Text(data.computeBody(name: viewStore.name))
                        .font(.title)
                        .opacity(isAnimationFinished ? 1 : 0)
                        .typeText(
                            text: $animatedTitle,
                            finalText: data.title,
                            isFinished: $isAnimationFinished,
                            speed: 30)
                        .animation(isAnimationFinished ? .easeOut(duration: 2) : .none,
                                   value: isAnimationFinished)
                        .navigationTitle(animatedTitle)
                }
            }
            .toolbar {
                makeButtons(Self.stepData[viewStore.step]?.buttons)
            }
//            .animation(.default, value: viewStore.step)
            .padding()
        }
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: Creature.ImmersiveView.ID) {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
        .frame(idealWidth: 600, idealHeight: 600)
    }
    
    @ToolbarContentBuilder
    func makeButtons(_ options: ButtonOptions?) -> some ToolbarContent {
        if options?.contains(.previous) ?? true {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Back", systemImage: "arrow.left") {
                    store.send(.previous)
                }
                .buttonBorderShape(.circle)
                .help("Back")
            }
        }
        if options?.contains(.skipAll) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Skip All", systemImage: "forward.end") {
                    store.send(.skipAll)
                }
                .buttonBorderShape(.circle)
                .help("Skip All")
            }
        }
        if options?.contains(.next) ?? true {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Continue", systemImage: "arrow.right") {
                    store.send(.next)
                }
                .buttonBorderShape(.circle)
                .help("Continue")
            }
        }
        if options?.contains(.close) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Close", systemImage: "xmark") {
                    // TODO: this should instead go to some control panel thing since a window is required to view the immersive space
                    store.send(.next)
                    dismissWindow(id: RootView.ID)
                    logger.debug("Attempted to dismiss window. [\(RootView.ID)]")
                }
                .buttonBorderShape(.circle)
                .help("Close")
            }
        }
        
    }
}

extension StepView {
    struct StepData {
        let title: String
        let body: String
        let buttons: ButtonOptions
        
        func computeBody(name: String) -> String {
            .init(format: body, name)
        }
    }

    struct ButtonOptions: OptionSet {
        let rawValue: Int
        static let next = Self(rawValue: 1 << 0)
        static let skipAll = Self(rawValue: 1 << 1)
        static let names = Self(rawValue: 1 << 2)
        static let micPermissions = Self(rawValue: 1 << 3)
        static let arPermissions = Self(rawValue: 1 << 4)
        static let showInterest = Self(rawValue: 1 << 5)
        static let close = Self(rawValue: 1 << 6)
        
        static let previous = Self(rawValue: 1 << 7)
        
        static let standard: Self = [.previous, .next, .skipAll]
    }
}
