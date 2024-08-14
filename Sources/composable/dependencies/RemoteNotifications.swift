//
//  RemoteNotifications.swift
//  swift-nth-core
//
//  Created by hung on 8/12/24.
//  adapted from isowords

import Dependencies
import DependenciesMacros

import UIKit

extension DependencyValues {
    public var remoteNotifications: RemoteNotificationsClient {
        get { self[RemoteNotificationsClient.self] }
        set { self[RemoteNotificationsClient.self] = newValue }
    }
}

@DependencyClient
public struct RemoteNotificationsClient {
    public var isRegistered: @Sendable () async -> Bool = { false }
    public var register: @Sendable () async -> Void
    public var unregister: @Sendable () async -> Void
}

@available(iOSApplicationExtension, unavailable)
extension RemoteNotificationsClient: DependencyKey {
    public static let liveValue = Self(
        isRegistered: { UIApplication.shared.isRegisteredForRemoteNotifications },
        register: { UIApplication.shared.registerForRemoteNotifications() },
        unregister: { UIApplication.shared.unregisterForRemoteNotifications() }
    )
}
