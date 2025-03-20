//
//  WorldTrackingProviderExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 3/20/25.
//

import ARKit
import QuartzCore

public extension WorldTrackingProvider {
    /// Wraps `queryDeviceAnchor` in a task, as it is computationally expensive.
    func queryDeviceAnchorNow() async -> DeviceAnchor? {
        await Task { queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) }.value
    }
}
