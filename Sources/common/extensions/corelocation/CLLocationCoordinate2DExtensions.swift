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

extension CLLocationCoordinate2D: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

public extension CLLocationCoordinate2D {
    func distance(to other: Self) -> CLLocationDistance {
        let origin: CLLocation = .init(latitude: latitude, longitude: longitude)
        let other: CLLocation = .init(latitude: other.latitude, longitude: other.longitude)
        return other.distance(from: origin)
    }
}
