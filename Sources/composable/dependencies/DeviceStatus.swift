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
    public struct BatteryState: RawRepresentable, Codable, Hashable {
        public let rawValue: Int

        public init?(rawValue: Int) {
            guard case .some = UIDevice.BatteryState(rawValue: rawValue) else {
                return nil
            }
            self.rawValue = rawValue
        }

        public static let unplugged: Self = .init(UIDevice.BatteryState.unplugged)
        public static let charging: Self = .init(UIDevice.BatteryState.charging)
        public static let unknown: Self = .init(UIDevice.BatteryState.unknown)
        public static let full: Self = .init(UIDevice.BatteryState.full)

        init(_ batteryState: UIDevice.BatteryState) {
            self.init(rawValue: batteryState.rawValue)!
        }
    }
}
