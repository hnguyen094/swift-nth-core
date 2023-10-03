//
//  TextDisplay.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import SwiftUI
import ComposableArchitecture

struct TextDisplay: Reducer {
    struct State: Equatable {
        var title: String
        var text: LocalizedStringKey
    }
    
    enum Action {}
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> { }
}
