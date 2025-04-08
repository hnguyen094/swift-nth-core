//
//  AppDelegate.swift
//  swift-nth-core
//
//  Created by hung on 8/13/24.
//

import ComposableArchitecture
import UIKit
#if canImport(NthComposableRemoteNotifications)
import NthComposableRemoteNotifications
#endif

public class AppDelegate: NSObject, UIApplicationDelegate {
    var store: StoreOf<Feature>!

    public func setup(store: StoreOf<Feature>) {
        self.store = store
    }

    public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        store.send(.didFinishLaunching)
        return true
    }

    #if canImport(NthComposableRemoteNotifications)
    public func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        store.send(.didRegisterForRemoteNotifications(.success(deviceToken)))
    }

    public func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: any Error
    ) {
        store.send(.didRegisterForRemoteNotifications(.failure(error)))
    }
    #endif
}

extension AppDelegate {
    @Reducer
    public struct Feature: Sendable {
        public init() { }

        @ObservableState
        public struct State: Equatable {}
        
        public enum Action {
            case didFinishLaunching
            #if canImport(NthComposableRemoteNotifications)
            case didRegisterForRemoteNotifications(Result<Data, Error>)
            #endif
            case userNotifications(UserNotificationClient.DelegateEvent)
        }

        @Dependency(\.userNotifications) var userNotifications
        #if canImport(NthComposableRemoteNotifications)
        @Dependency(\.remoteNotifications.register) var registerForRemoteNotifications
        #endif
        public var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .didFinishLaunching:
                    let notificationsStream = userNotifications.delegate()
                    return .run { send in
                        await withThrowingTaskGroup(of: Void.self) { group in
                            group.addTask {
                                for await event in notificationsStream {
                                    await send(.userNotifications(event))
                                }
                            }
                            group.addTask {
                                let settings = await userNotifications.getNotificationSettings()
                                switch settings.authorizationStatus {
                                case .authorized:
                                    guard try await userNotifications
                                        .requestAuthorization([.alert, .sound])
                                    else { return }
                                case .notDetermined, .provisional:
                                    guard try await userNotifications
                                        .requestAuthorization(.provisional)
                                    else { return }
                                default:
                                    return
                                }
                                #if canImport(NthComposableRemoteNotifications)
                                await registerForRemoteNotifications()
                                #endif
                            }
                        }
                    }
                #if canImport(NthComposableRemoteNotifications)
                case .didRegisterForRemoteNotifications:
                    return .none
                #endif
                case .userNotifications(let event):
                    return .run { _ in
                        guard case .willPresentNotification(_, completionHandler: let handler) = event
                        else { return }
                        handler(.banner)
                    }
                }
            }
        }
    }
}
