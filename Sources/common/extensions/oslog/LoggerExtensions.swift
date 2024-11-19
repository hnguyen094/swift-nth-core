//
//  LoggerExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 9/26/24.
//
// https://www.avanderlee.com/debugging/oslog-unified-logging/

import OSLog

public extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.nth.unknown"

    static let app: Self = Self(subsystem: subsystem, category: "main")

    static func app(category: String) -> Self {
        return .init(subsystem: subsystem, category: category)
    }
}
