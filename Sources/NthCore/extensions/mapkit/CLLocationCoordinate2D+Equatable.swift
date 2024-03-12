//
//  CLLocationCoordinate2D+Equatable.swift
//  flaky-mvp
//
//  Created by hung on 2/23/24.
//

import MapKit

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
