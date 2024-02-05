//
//  App.Feature.State+Extension.swift
//  keepers-tech-demo
//
//  Created by hung on 2/5/24.
//

import Foundation

// MARK: Previously ViewState
extension demoApp.Feature.State {
    var runOptions: Creature.Understanding.RunOptions? {
        self.creature.understanding?.runOptions
    }

    var usingSoundAnalysis: Bool {
        self.runOptions?.contains(.soundAnalysis) ?? false
    }

    var name: String {
        self.creature.name
    }
}
