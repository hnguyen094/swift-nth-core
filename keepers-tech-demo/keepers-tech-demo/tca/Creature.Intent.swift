//
//  Creature.Intent.swift
//  keepers-tech-demo
//
//  Created by hung on 1/21/24.
//

import Foundation

extension Creature {
    struct Intent: Equatable, Codable {
        var emotionAnimation: Emoting.Animation = .idle
        var textBubble: String? = .none
        var squareness: Float = 1
    }
}
