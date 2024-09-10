//
//  DeviceStatus.swift
//  keepers
//
//  Created by Hung Nguyen on 9/7/24.
//

import Dependencies
import DependenciesMacros
import CasePaths

import UIKit

public extension DependencyValues {
    var deviceStatus: DeviceStatus {
        get { self[DeviceStatus.self] }
        set { self[DeviceStatus.self] = newValue }
    }
}

@DependencyClient
public struct DeviceStatus {
    public var getBatteryState: () -> BatteryState = { .unknown }
    public var getBatteryLevel: () -> Float = { -1.0 }
}

extension DeviceStatus: DependencyKey {
    public static var liveValue: Self {
        let device: UIDevice = .current
        device.isBatteryMonitoringEnabled = true
        return .init(
            getBatteryState:  { .init(device.batteryState) },
            getBatteryLevel: { device.batteryLevel }
        )
    }
}

// this is necessary because UIDevice.BatteryState directly with @retroactive Codable causes a bug
// with SwiftData/Apple's llvm.
extension DeviceStatus {
    public enum BatteryState: Int, Codable {
        case unknown = 0
        case unplugged = 1
        case charging = 2
        case full = 3

        init(_ batteryState: UIDevice.BatteryState) {
            self.init(rawValue: batteryState.rawValue)!
        }

        public var uiBatteryState: UIDevice.BatteryState {
            .init(rawValue: self.rawValue)!
        }
    }
}
