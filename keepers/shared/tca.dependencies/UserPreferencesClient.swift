//
//  UserPreferencesClient.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Data Storage.

import Dependencies

extension DependencyValues {
    var userPreferences: UserPreferencesClient {
        get { self[UserPreferencesClient.self] }
        set { self[UserPreferencesClient.self] = newValue }
    }
}

// should instead use iCloud packing keystore
//private enum UserDefaultsKeys: DependencyKey {
//    // could instead use App Groups to share UserDefaults w/ visionOS
//    static let liveValue = UserDefaults.standard
//}
struct UserPreferencesClient {
    var savePreference: (_ key: String, _ value: Encodable) -> Void
    var loadPreference: (_ key: String) -> Decodable
}


extension UserPreferencesClient: DependencyKey {
    /// TODO: implement
    static var liveValue: Self {
        return unimplementedClient
    }
    
    // could instead use App Groups to share UserDefaults w/ visionOS
    // and use UserDefaults.group
    // static let userDefaultsClient = Self(/**/)
    
    // or instead use NSUbiquitousKeyValueStore
    // static let cloudKitClient = Self(/**/)

    static let unimplementedClient = Self(
        savePreference: {_,_ in unimplemented("UserPreferencesClient.savePreference")},
        loadPreference: {_ in unimplemented("UserPreferencesClient.loadPreference")} )
}
