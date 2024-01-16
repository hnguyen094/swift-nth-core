//
//  Windowed.swift
//  keepers-tech-demo
//
//  Created by hung on 1/16/24.
//

import Dependencies

extension DependencyValues {
    var windowed: Bool {
        get { self[WindowedKey.self] }
        set { self[WindowedKey.self] = newValue }
    }
    
    private enum WindowedKey: DependencyKey {
        static let liveValue = false
    }
}
