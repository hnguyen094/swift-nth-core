//
//  TextBubble.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//

import SwiftUI
import ComposableArchitecture

struct TextBubble: View {
    @Bindable var store: StoreOf<Creature.Feature>
    
    @State var text: String = ""
    
    @Dependency(\.logger) var logger

    var body: some View {
        WithViewStore(store, observe: \.intent.textBubble) { viewStore in
            let visible = viewStore.state != .none
            ZStack {
                Text(text)
                    .monospaced()
                    .padding()
                    .frame(minWidth: 50, alignment: .center)
                    .glassBackgroundEffect()
                    .offset(x: 0, y: visible ? 0 : 50)
                    .typeText(
                        text: $text,
                        finalText: viewStore.state,
                        speed: 20)
                    .animation(.easeOut(duration: visible ? 1.5 : 1), value: visible)
                Circle()
                    .frame(width: 30, height: 25)
                    .foregroundColor(.clear)
                    .glassBackgroundEffect()
                    .offset(x: 0, y: visible ? 30 : 50)
                    .offset(z: visible ? -3 : 0)
                    .animation(.easeOut(duration: 1.1), value: visible)
                Circle()
                    .frame(width: 12, height: 10)
                    .foregroundColor(.clear)
                    .glassBackgroundEffect()
                    .offset(x: 0, y: visible ? 45 : 50)
                    .offset(z: visible ? -6 : 0)
                    .animation(.easeOut(duration: visible ? 1 : 1.5), value: visible)
            }
            .opacity(visible ? 1 : 0)
            .animation(.default, value: visible)
        }
    }
}
