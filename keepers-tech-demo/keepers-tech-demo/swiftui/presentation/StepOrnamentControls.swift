//
//  StepOrnamentControls.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import SwiftUI
import ComposableArchitecture

extension demoApp {
    @ToolbarContentBuilder
    static func ornamentButtons(
        _ store: StoreOfView,
        _ options: ButtonOptions?)
    -> some ToolbarContent {
        if options?.contains(.previous) ?? true {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Back", systemImage: "arrow.left") {
                    store.send(.previous)
                }
                .buttonBorderShape(.circle)
                .help("Back")
            }
        }
        
        if options?.contains(.restart) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Restart", systemImage: "arrow.counterclockwise") {
                    store.send(.set(\.$step, .heroScreen))
                }
                .buttonBorderShape(.circle)
                .help("Start From Beginning")
            }
        }
        
//        if options?.contains(.skipAll) ?? false {
//            ToolbarItem(placement: .bottomOrnament) {
//                Button("Skip All", systemImage: "forward.end") {
//                    store.send(.set(\.$step, .futureDevelopment))
//                }
//                .buttonBorderShape(.circle)
//                .help("Skip All")
//            }
//        }
        if options?.contains(.next) ?? true {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Continue", systemImage: "arrow.right") {
                    store.send(.next)
                }
                .buttonBorderShape(.circle)
                .help("Continue")
            }
        }
        if options?.contains(.showInterest) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                WithViewStore(store, observe: \.voteCount) { viewStore in
                    let hasValue = viewStore.state != .none
                    if hasValue {
                        Button("+\(viewStore.state!)", systemImage: "hand.thumbsup.fill") {
                            store.send(.vote)
                        }
                        .labelStyle(.titleAndIcon)
                        .help("Show Interest")
                        .animation(.spring, value: viewStore.state)
                    } else {
                        Button("Show Interest", systemImage: "hand.thumbsup") {
                            store.send(.vote)
                        }
                        .buttonBorderShape(.circle)
                        .help("Show Interest")
                    }
                }
            }
        }
        if options?.contains(.goToControls) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Done", systemImage: "checkmark") {
                    // TODO: this should instead go to some control panel thing since a window is required to view the immersive space
                    store.send(.set(\.$step, .controls))
                }
                .buttonBorderShape(.circle)
                .help("Done")
            }
        }
    }
}
