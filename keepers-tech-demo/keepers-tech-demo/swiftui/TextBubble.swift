//
//  TextBubble.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//

import SwiftUI
import ComposableArchitecture

struct TextBubble: View {
    let store: StoreOf<Creature.Feature>
    
    @Dependency(\.logger) var logger

    var body: some View {
        WithViewStore(store, observe: \.textBubble) { viewStore in
            let visible = viewStore.state != .none

            ZStack {
                Text(viewStore.state ?? "")
                    .padding()
                    .glassBackgroundEffect()
                Circle()
                    .frame(width: 30, height: 25)
                    .foregroundColor(.clear)
                    .glassBackgroundEffect()
                    .offset(x: 0, y: visible ? 30 : 0)
                    .offset(z: visible ? -3 : 0)
                    .animation(.easeOut(duration: 1.2), value: visible)
                Circle()
                    .frame(width: 12, height: 10)
                    .foregroundColor(.clear)
                    .glassBackgroundEffect()
                    .offset(x: 0, y: visible ? 45 : 0)
                    .offset(z: visible ? -6 : 0)
                    .animation(.easeOut(duration: 1.5), value: visible)
            }
            .opacity(visible ? 1 : 0)
            .animation(.default, value: visible)
            
//            if let text = viewStore.state {
//                ZStack {
//                    Text(text)
//                        .padding()
//                        .glassBackgroundEffect()
//                    Circle()
//                        .frame(width: 30, height: 25)
//                        .foregroundColor(.clear)
//                        .glassBackgroundEffect()
//                        .offset(x: 0, y: 30)
//                        .offset(z: -3)
//                        .animation(.easeOut(duration: 3), value: viewStore.state)
//                    Circle()
//                        .frame(width: 12, height: 10)
//                        .foregroundColor(.clear)
//                        .glassBackgroundEffect()
//                        .offset(x: 0, y: 45)
//                        .offset(z: -6)
//                        .animation(.easeOut(duration: 3), value: viewStore.state)
//                }
//                
//            }
        }
    }
}
