//
//  Logger.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Logger Systems.

import Dependencies
import OSLog

extension DependencyValues {
    
    /// - Important: This is being used like a global attached to Dependencies, rather than actually propagating correctly through some single-entry
    /// code system.
    public var logger: Logger {
        get { self[MainLogger.self] }
        set { self[MainLogger.self] = newValue }
    }
    
    public var statsLogger: Logger {
        get { self[StatisticsLogger.self] }
        set { self[StatisticsLogger.self] = newValue }
    }
    
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.nth.unknown"

    private enum MainLogger: DependencyKey {
        static let liveValue = Logger(subsystem: subsystem, category: "main")
    }
    private enum StatisticsLogger: DependencyKey {
        static let liveValue = Logger(subsystem: subsystem, category: "statistics")
    }
}
