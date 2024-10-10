//
//  UserNotifications.swift
//  swift-nth-core
//
//  Created by hung on 8/12/24.
//  adapted from isowords

import Dependencies
import DependenciesMacros
import CasePaths
import UserNotifications

extension DependencyValues {
    public var userNotifications: UserNotificationClient {
        get { self[UserNotificationClient.self] }
        set { self[UserNotificationClient.self] = newValue }
    }
}

@DependencyClient
public struct UserNotificationClient: Sendable {
    public var add: @Sendable (UNNotificationRequest) async throws -> Void
    public var delegate: @Sendable () -> AsyncStream<DelegateEvent> = { .finished }
    public var getNotificationSettings: @Sendable () async -> Notification.Settings = {
        Notification.Settings(authorizationStatus: .notDetermined)
    }
    public var removeDeliveredNotificationsWithIdentifiers: @Sendable ([String]) async -> Void
    public var removePendingNotificationRequestsWithIdentifiers: @Sendable ([String]) async -> Void
    public var requestAuthorization: @Sendable (UNAuthorizationOptions) async throws -> Bool

    // TODO: we pretend this is sendable as we don't plan on using it outside yielding directly
    // to the continuation.
    @CasePathable
    public enum DelegateEvent: @unchecked Sendable {
        case didReceiveResponse(Notification.Response, completionHandler: () -> Void)
        case openSettingsForNotification(Notification?)
        case willPresentNotification(
            Notification, completionHandler: (UNNotificationPresentationOptions) -> Void
        )
    }

    public struct Notification: Equatable {
        public var date: Date
        public var request: UNNotificationRequest

        public init(
            date: Date,
            request: UNNotificationRequest
        ) {
            self.date = date
            self.request = request
        }

        public struct Response: Equatable {
            public var notification: Notification

            public init(notification: Notification) {
                self.notification = notification
            }
        }

        public struct Settings: Equatable, Sendable {
            public var authorizationStatus: UNAuthorizationStatus

            public init(authorizationStatus: UNAuthorizationStatus) {
                self.authorizationStatus = authorizationStatus
            }
        }
    }
}

extension UserNotificationClient: DependencyKey {
    public static let liveValue: Self = {
        return Self(
            add: { try await UNUserNotificationCenter.current().add($0) },
            delegate: {
                AsyncStream { continuation in
                    let delegate = Delegate(continuation: continuation)
                    UNUserNotificationCenter.current().delegate = delegate
                    // TODO: commented out due to Sendable conformances, might need fix.
//                    continuation.onTermination = { _ in
//                        _ = delegate
//                    }
                }
            },
            getNotificationSettings: {
                await Notification.Settings(
                    rawValue: UNUserNotificationCenter.current().notificationSettings()
                )
            },
            removeDeliveredNotificationsWithIdentifiers: {
                UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: $0)
            },
            removePendingNotificationRequestsWithIdentifiers: {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: $0)
            },
            requestAuthorization: {
                try await UNUserNotificationCenter.current().requestAuthorization(options: $0)
            }
        )
    }()
}

extension UserNotificationClient.Notification {
    public init(rawValue: UNNotification) {
        self.date = rawValue.date
        self.request = rawValue.request
    }
}

extension UserNotificationClient.Notification.Response {
    public init(rawValue: UNNotificationResponse) {
        self.notification = .init(rawValue: rawValue.notification)
    }
}

extension UserNotificationClient.Notification.Settings {
    public init(rawValue: UNNotificationSettings) {
        self.authorizationStatus = rawValue.authorizationStatus
    }
}

extension UserNotificationClient {
    fileprivate class Delegate: NSObject, UNUserNotificationCenterDelegate {
        let continuation: AsyncStream<DelegateEvent>.Continuation

        init(continuation: AsyncStream<DelegateEvent>.Continuation) {
            self.continuation = continuation
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            self.continuation.yield(
                .didReceiveResponse(.init(rawValue: response)) { completionHandler() }
            )
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            openSettingsFor notification: UNNotification?
        ) {
            self.continuation.yield(
                .openSettingsForNotification(notification.map(Notification.init(rawValue:)))
            )
        }

        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler:
            @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            self.continuation.yield(
                .willPresentNotification(.init(rawValue: notification)) { completionHandler($0) }
            )
        }
    }
}
