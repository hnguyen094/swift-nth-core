//
//  Dependencies.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  To see what `unimplemented` is, follow [here](https://pointfreeco.github.io/swift-dependencies/main/documentation/dependencies/designingdependencies/ ).

import Foundation
import Dependencies

import OSLog

// MARK: Summary of dependencies.
extension DependencyValues {
    var userPreferences: UserPreferencesClient {
        get { self[UserPreferencesClient.self] }
        set { self[UserPreferencesClient.self] = newValue }
    }
    
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
    
    var logger: Logger {
        get { self[LoggerClient.Main.self] }
        set { self[LoggerClient.Main.self] = newValue }
    }
    
    var statsLogger: Logger {
        get { self[LoggerClient.Stats.self] }
        set { self[LoggerClient.Stats.self] = newValue }
    }
}

// MARK: Data storage. (AudioPlayerClient)

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

// MARK: Audio System. (AudioPlayerClient)

struct AudioPlayerClient {
    var getVolume: (_ type: AudioCategory) -> Float
    
    var loop: (_ url: URL, _ type: AudioCategory) async throws -> Void
    var play: (_ url: URL, _ type: AudioCategory) async throws -> Void
    var setVolume: (_ volume: Float, _ type: AudioCategory) async -> Void
    var stop: (_ type: AudioCategory) async -> Void
        
    enum AudioCategory: CaseIterable {
        case main
        case music
        case pet
        case sfx
    }
}

extension AudioPlayerClient: DependencyKey {
    /// TODO: implement
    static var liveValue: Self {
        return unimplementedClient
    }
    static let unimplementedClient = Self(
        getVolume: { _ in unimplemented("AudioPlayerClient.getVolume") },
        loop: { _,_ in unimplemented("AudioPlayerClient.loop") },
        play: { _,_ in  unimplemented("AudioPlayerClient.play") },
        setVolume: { _,_ in unimplemented("AudioPlayerClient.setVolume")  },
        stop: { _ in unimplemented("AudioPlayerClient.stop")  }
    )
}

// MARK: Logging System. (LoggerClient)


struct LoggerClient {
    private static let subsystem = Bundle.main.bundleIdentifier!

    enum Main: DependencyKey {
        static var liveValue = Logger(subsystem: subsystem, category: "main")
    }
    enum Stats: DependencyKey {
        static var liveValue = Logger(subsystem: subsystem, category: "stat")
    }
}
