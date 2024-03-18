//
//  Maps.swift
//  flaky-mvp
//
//  Created by hung on 3/12/24.
//

import Dependencies
import DependenciesMacros

import MapKit

extension DependencyValues {
    public var maps: Maps {
        get { self[Maps.self] }
        set { self[Maps.self] = newValue }
    }
}

@DependencyClient
public struct Maps {
    public var lookup: (_ query: String) async throws -> [MKMapItem]
    public var openInMaps: (_ location: CLLocation, _ name: String) -> Void
}

extension Maps: DependencyKey {
    public static let testValue: Self = .init()
    public static let previewValue: Self = .init()
    public static var liveValue: Self {
        return .init(
            lookup: { query in
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = query
                let search = MKLocalSearch(request: searchRequest)
                let response = try await search.start()
                return response.mapItems
            },
            openInMaps: { location, name in
                let placemark = MKPlacemark(coordinate: location.coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = name
                mapItem.openInMaps(launchOptions: .none)
            })
    }
}
