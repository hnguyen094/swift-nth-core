//
//  Globals.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import OSLog
// MARK: Logging

/// Bundle identifier to identify subsystem when logging.
private let subsystem = Bundle.main.bundleIdentifier!

/// Standard default logging for the application.
let logger = Logger(subsystem: subsystem, category: "main")

/// All logs related to tracking and analytics.
let loggerStat = Logger(subsystem: subsystem, category: "stat")
