//
//  LoggerClient.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Logger Systems.

import Dependencies
import OSLog

extension DependencyValues {
    public var logger: Logger {
        get { self[MainLogger.self] }
        set { self[MainLogger.self] = newValue }
    }
    
    public var statsLogger: Logger {
        get { self[StatisticsLogger.self] }
        set { self[StatisticsLogger.self] = newValue }
    }
    
    private static let subsystem = Bundle.main.bundleIdentifier!

    private enum MainLogger: DependencyKey {
        static let liveValue = Logger(subsystem: subsystem, category: "main")
    }
    private enum StatisticsLogger: DependencyKey {
        static let liveValue = Logger(subsystem: subsystem, category: "statistics")
    }
}
