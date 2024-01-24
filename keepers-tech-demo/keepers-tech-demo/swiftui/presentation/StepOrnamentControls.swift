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
    static func ornamentButtons(_ store: Store<demoApp.ViewState, demoApp.Feature.Action>
, _ options: ButtonOptions?) -> some ToolbarContent {
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
        
        if options?.contains(.skipAll) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                Button("Skip All", systemImage: "forward.end") {
                    store.send(.set(\.$step, .futureDevelopment))
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
        if options?.contains(.showInterest) ?? false {
            ToolbarItem(placement: .bottomOrnament) {
                Button("+1", systemImage: "hand.thumbsup.fill") {
                    store.send(.vote)
                }
                .labelStyle(.titleAndIcon)
                .help("Show Interest")
            }
        }
    }
}
