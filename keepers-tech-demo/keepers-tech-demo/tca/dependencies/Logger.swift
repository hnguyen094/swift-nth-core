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
    var logger: Logger {
        get { self[LoggerClient.Main.self] }
        set { self[LoggerClient.Main.self] = newValue }
    }
    
    var statsLogger: Logger {
        get { self[LoggerClient.Stats.self] }
        set { self[LoggerClient.Stats.self] = newValue }
    }
}

struct LoggerClient {
    private static let subsystem = Bundle.main.bundleIdentifier!

    enum Main: DependencyKey {
        static let liveValue = Logger(subsystem: subsystem, category: "Keepers")
    }
    enum Stats: DependencyKey {
        static let liveValue = Logger(subsystem: subsystem, category: "Keepers.Stats")
    }
}
