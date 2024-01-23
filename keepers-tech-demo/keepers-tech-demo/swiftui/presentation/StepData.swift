//
//  StepData.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import Foundation

extension demoApp {
    struct StepData {
        let title: String
        let body: String
        let buttons: ButtonOptions
        
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
        static let goToControls = Self(rawValue: 1 << 6)
        
        static let previous = Self(rawValue: 1 << 7)
        static let restart = Self(rawValue: 1 << 8)
        
        static let standard: Self = [.previous, .next, .skipAll]
    }
}
