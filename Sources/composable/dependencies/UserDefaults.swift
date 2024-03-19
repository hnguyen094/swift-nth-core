//
//  UserDefaults.swift
//  swift-nth-core
//
//  Created by hung on 2/7/24.
//

import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
    public var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

// could instead use App Groups to share UserDefaults w/ visionOS
// and use UserDefaults.group
// static let userDefaultsClient = Self(/**/)

// or instead use NSUbiquitousKeyValueStore
// static let cloudKitClient = Self(/**/)

@DependencyClient
public struct UserDefaultsClient {
    public var boolForKey: @Sendable (String) -> Bool = { _ in false }
    public var dataForKey: @Sendable (String) -> Data?
    public var doubleForKey: @Sendable (String) -> Double = { _ in 0 }
    public var integerForKey: @Sendable (String) -> Int = { _ in 0 }
    public var remove: @Sendable (String) async -> Void
    public var setBool: @Sendable (Bool, String) async -> Void
    public var setData: @Sendable (Data?, String) async -> Void
    public var setDouble: @Sendable (Double, String) async -> Void
    public var setInteger: @Sendable (Int, String) async -> Void
}

extension UserDefaultsClient: DependencyKey {
    public static var testValue: Self = .init()
    public static var previewValue: Self = .init()
    public static var liveValue: Self {
        let defaults = { UserDefaults.standard }
        return .init(
          boolForKey: { defaults().bool(forKey: $0) },
          dataForKey: { defaults().data(forKey: $0) },
          doubleForKey: { defaults().double(forKey: $0) },
          integerForKey: { defaults().integer(forKey: $0) },
          remove: { defaults().removeObject(forKey: $0) },
          setBool: { defaults().set($0, forKey: $1) },
          setData: { defaults().set($0, forKey: $1) },
          setDouble: { defaults().set($0, forKey: $1) },
          setInteger: { defaults().set($0, forKey: $1) }
        )
    }
}
