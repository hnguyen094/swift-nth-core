//
//  Task+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//

import Combine

public extension Task {
    func eraseToAnyCancellable() -> AnyCancellable {
        AnyCancellable(cancel)
    }
}
