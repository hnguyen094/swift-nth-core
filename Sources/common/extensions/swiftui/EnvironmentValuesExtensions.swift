//
//  EnvironmentValuesExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 10/24/24.
//

import SwiftUI

public extension EnvironmentValues {
    var iso8601Local: Date.ISO8601FormatStyle { .iso8601(timeZone: self.timeZone) }
}
