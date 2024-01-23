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

    @State private var text: String
    @State private var isFinished: Bool
    
    var body: some View {
        Text("my ami")
            .font(.extraLargeTitle)
        Text(text)
            .font(.extraLargeTitle2)
            .typeText(
                text: $text,
                finalText: "tech demo",
                isFinished: $isFinished)
            .monospaced()
            .onChange(of: isFinished) {
                store.send(.next)
            }
    }
}

struct StepView: View {
    typealias Step = keepers_tech_demoApp.Step
    let store: Store<ViewState, keepers_tech_demoApp.Feature.Action>
    
    @State private var animatedTitle: String

    struct ViewState: Equatable {
        var step: Step
        var name: String
        
        init(state: keepers_tech_demoApp.Feature.State) {
            step = state.step
            name = state.name
        }
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let data = Self.stepData[viewStore.step] {
                Text(animatedTitle)
                    .font(.title)
                    .typeText(text: $animatedTitle, finalText: data.title)
                Text(data.body)
                    .font(.body)
                if data.buttons.contains(.next) {
                    Button("Continue") {
                        store.send(.next)
                    }
                    .frame(alignment: .bottom)
                }
                if data.buttons.contains(.skipAll) {
                    Button("Skip All") {
                        store.send(.skipAll)
                    }
                    .frame(alignment: .topTrailing)
                }
            } else {
                Button("Continue") {
                    store.send(.next)
                }
            }
        }
    }
}

extension StepView {
    struct StepData {
        var title: String
        var body: String
        var buttons: ButtonOptions
        
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
        
        static let standard: Self = [.next, .skipAll]
    }
}
