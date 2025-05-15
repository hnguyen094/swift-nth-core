//
//  CelestialCalculator.swift
//  keepers
//
//  Created by Hung Nguyen on 9/19/24.
//  Solar Position Algorithm

#if canImport(SunCalc)
import Dependencies
import DependenciesMacros

import CoreLocation
import SunCalc

public extension DependencyValues {
    var celestialCalculator: CelestialCalculator {
        get { self[CelestialCalculator.self] }
        set { self[CelestialCalculator.self] = newValue }
    }
}

@DependencyClient
public struct CelestialCalculator {
    public struct SunData: Codable, Hashable {
        public let altitude: Double
        public let azimuth: Double
        public let rise: Date?
        public let set: Date?
    }

    public struct MoonData: Codable, Hashable {
        public let altitude: Double
        public let azimuth: Double
        public let rise: Date?
        public let set: Date?
        public let illuminated: Double
        public let phaseValue: Double
        public let closestPhase: Phase

        public enum Phase: Int, Codable {
            case newMoon = 0
            case waxingCrescent = 45
            case firstQuarter = 90
            case waxingGibbous = 135
            case fullMoon = 180
            case waningGibbous = 225
            case lastQuarter = 270
            case waningCrescent = 315
        }
    }

    public var sunData: @Sendable (_ location: CLLocation) throws -> SunData
    public var moonData: @Sendable (_ location: CLLocation) throws -> MoonData
}

extension CelestialCalculator: Sendable, DependencyKey {
    public static var liveValue: Self {
        .init(
            sunData: { location in
                let sunTimes = try SunTimes.compute()
                    .on(location.timestamp)
                    .latitude(location.coordinate.latitude)
                    .longitude(location.coordinate.longitude)
                    .height(location.altitude)
                    .execute()
                let sunPosition = try SunPosition.compute()
                    .on(location.timestamp)
                    .latitude(location.coordinate.latitude)
                    .longitude(location.coordinate.longitude)
                    .height(location.altitude)
                    .execute()
                return SunData(
                    altitude: sunPosition.altitude,
                    azimuth: sunPosition.azimuth,
                    rise: sunTimes.rise?.date,
                    set: sunTimes.set?.date)
            },
            moonData: { location in
                let moonTimes = try MoonTimes.compute()
                    .on(location.timestamp)
                    .latitude(location.coordinate.latitude)
                    .longitude(location.coordinate.longitude)
                    .height(location.altitude)
                    .execute()
                let moonPosition = try MoonPosition.compute()
                    .on(location.timestamp)
                    .latitude(location.coordinate.latitude)
                    .longitude(location.coordinate.longitude)
                    .height(location.altitude)
                    .execute()
                let moonIllumination = try MoonIllumination.compute()
                    .on(location.timestamp)
                    .latitude(location.coordinate.latitude)
                    .longitude(location.coordinate.longitude)
                    .height(location.altitude)
                    .execute()
                return MoonData(
                    altitude: moonPosition.altitude,
                    azimuth: moonPosition.azimuth,
                    rise: moonTimes.rise?.date,
                    set: moonTimes.set?.date,
                    illuminated: moonIllumination.fraction,
                    phaseValue: moonIllumination.phase,
                    closestPhase: moonIllumination.closestPhase.phase
                )
            }
        )
    }
}

fileprivate extension DateTime {
    var date: Date { .init(timeIntervalSince1970: self.timeIntervalSince1970) }
}

fileprivate extension Phase {
    var phase: CelestialCalculator.MoonData.Phase {
        let phase = Self.toPhase(self.angle)
        return switch phase {
        case .newMoon: .newMoon
        case .waxingCrescent: .waxingCrescent
        case .firstQuarter: .firstQuarter
        case .waxingGibbous: .waxingGibbous
        case .fullMoon: .fullMoon
        case .waningGibbous: .waningGibbous
        case .lastQuarter: .lastQuarter
        case .waningCrescent: .waningCrescent
        default: .newMoon
        }
    }
}
#endif
