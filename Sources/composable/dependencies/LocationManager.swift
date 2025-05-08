//
//  LocationManager.swift
//  keepers
//
//  Created by Hung Nguyen on 9/16/24.
//

import Dependencies
import DependenciesMacros
import CasePaths

import CoreLocation

extension DependencyValues {
    public var locationManager: LocationManagerClient {
        get { self[LocationManagerClient.self] }
        set { self[LocationManagerClient.self] = newValue }
    }
}

fileprivate extension String {
    static var fullAccuracyPurposeKey: Self { "userAction" }
    static var monitorName: Self { "locationMonitor" }
}

@DependencyClient
public struct LocationManagerClient: Sendable {
    public var location: @Sendable (_ precise: Bool) async throws -> CLLocation?
    public var addMonitorLocation: @Sendable (
        _ coords: CLLocationCoordinate2D,
        _ id: String
    ) async throws -> Void
    public var removeMonitorLocation: @Sendable (_ id: String) async throws -> Void
}

extension LocationManagerClient {
    // Note: this is a hacky workaround that might break in the future. It involves predicting when
    // the additional full accuracy prompt is shown, and assumes that there is a spurious update
    // before this prompt is shown that we should ignore.
    @MainActor static var fullAccuracyPromptWillShow: Bool = true

    @MainActor
    fileprivate static func setFullAccuracyPromptWillShow(_ value: Bool) {
        fullAccuracyPromptWillShow = value
    }

    @Sendable
    fileprivate static func location(precise: Bool) async throws -> CLLocation? {
        let _: CLServiceSession = precise
        ? .init(authorization: .whenInUse, fullAccuracyPurposeKey: .fullAccuracyPurposeKey)
        : .init(authorization: .whenInUse)

        var validUpdates = CLLocationUpdate.liveUpdates()
            .filter {
                !$0.authorizationRequestInProgress &&
                ($0.authorizationDenied || $0.locationUnavailable || $0.location != .none)
            }
            .makeAsyncIterator()

        guard let firstUpdate = try await validUpdates.next() else { return .none }
        guard precise && firstUpdate.accuracyLimited else {
            return firstUpdate.location
        }
        if await fullAccuracyPromptWillShow {
            await setFullAccuracyPromptWillShow(false)
            let secondUpdate = try await validUpdates.next()!
            return secondUpdate.accuracyLimited ? .none : secondUpdate.location
        }
        return Optional<CLLocation>.none
    }
}

// TODO: Macro codegen was fighting compilation condition; otherwise don't compile endpoints.
extension LocationManagerClient: DependencyKey {
#if os(visionOS)
    public static var liveValue: Self {
        Self(
            location: Self.location(precise:),
            addMonitorLocation: { _, _ in
                throw Unimplemented("addMonitorLocation is not supported on visionOS")
            },
            removeMonitorLocation: { _ in
                throw Unimplemented("removeMonitorLocation is not supported on visionOS")
            }
        )
    }
#else
    public static var liveValue: Self {
        let client = LiveMonitorClient()
        return Self(
            location: Self.location(precise:),
            addMonitorLocation: client.addMonitorLocation(_:id:),
            removeMonitorLocation: client.removeMonitorLocation(id:)
        )
    }

    private actor LiveMonitorClient {
        private var monitor: CLMonitor? = .none // actor protects concurrent access to this variable

        private func monitor() async -> CLMonitor {
            if case .none = self.monitor {
                self.monitor = await CLMonitor(.monitorName)
            }
            return self.monitor!
        }

        @Sendable
        func events() async -> CLMonitor.Events { await self.monitor().events }

        @Sendable
        func addMonitorLocation(_ coordinates: CLLocationCoordinate2D, id: String) async {
            let monitor = await self.monitor()
            let geographicCondition: CLMonitor.CircularGeographicCondition = .init(
                center: coordinates,
                radius: 20 // unlikely to be this accurate (expect 200m)
            )
            await monitor.add(geographicCondition, identifier: id)
        }

        @Sendable
        func removeMonitorLocation(id: String) async {
            let monitor = await self.monitor()
            await monitor.remove(id)
        }
    }
#endif
}
