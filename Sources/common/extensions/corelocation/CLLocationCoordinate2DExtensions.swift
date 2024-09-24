//
//  CLLocationCoordinate2D+Equatable.swift
//  flaky-mvp
//
//  Created by hung on 2/23/24.
//

import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension CLLocationCoordinate2D: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try values.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try values.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

fileprivate extension CLLocationDegrees {
    var radians: Double { self * .pi / 180 }
}

// https://community.fabric.microsoft.com/t5/Desktop/How-to-calculate-lat-long-distance/td-p/1488227
public extension CLLocationCoordinate2D {
    func distance(to other: Self) -> Double {
        return acos(
            sin(self.latitude.radians) * sin(other.latitude.radians) + cos(self.latitude.radians) *
            cos(other.latitude.radians) * cos(other.longitude.radians - self.longitude.radians)
        ) * 6_371_000 // Earth's radius in meters
    }
}
