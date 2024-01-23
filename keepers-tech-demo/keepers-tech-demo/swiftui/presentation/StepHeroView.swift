//
//  StepHeroView.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

extension demoApp {
    struct StepHeroView: View {
        typealias Step = demoApp.Step
        let store: StoreOf<demoApp.Feature>
        
        @State private var text: String = ""
        @State private var isFinished: Bool = false
        
        private static let subtitleText = "tech demo"
        
        var body: some View {
            VStack {
                Text("my ami")
                    .font(.extraLargeTitle)
                Text(Self.subtitleText)
                    .font(.extraLargeTitle2)
                    .monospaced()
                    .padding(.horizontal, 50)
                    .hidden()
                    .overlay(alignment: .leading) {
                        Text(text)
                            .font(.extraLargeTitle2)
                            .monospaced()
                            .padding(.leading, 50)
                            .typeText(
                                text: $text,
                                finalText: Self.subtitleText,
                                isFinished: $isFinished)
                    }
                    .onChange(of: isFinished) {
                        Task {
                            try? await Task.sleep(for: .milliseconds(500))
                            _ = withAnimation {
                                store.send(.next)
                            }
                        }
                    }
            }
            .frame(width: 800, height: 600)
        }
    }}
