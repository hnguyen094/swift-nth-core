//
//  AudioSession.swift
//  keepers-tech-demo
//
//  Created by hung on 1/19/24.
//

import Dependencies
import DependenciesMacros
import AVFoundation

extension DependencyValues {
    public var audioSession: AudioSession {
        get { self[AudioSession.self] }
        set { self[AudioSession.self] = newValue }
    }    
}

@DependencyClient
public struct AudioSession: Sendable {
    public var active: @Sendable () async -> Bool = { false }
    public var initialize: @Sendable (Configuration) async throws -> Void
    public var anotherAppIsPlayingMusicUpdates: @Sendable () throws -> any AsyncSequence<AVAudioSession.SilenceSecondaryAudioHintType, Never>
    public var anotherAppIsPlayingMusic: @Sendable () -> Bool = { false }
    public var anotherAppIsPlayingSound: @Sendable () -> Bool = { false }
}

extension AudioSession: DependencyKey {
    public static var liveValue: Self {
        let client = Client()

        return .init(
            active: { await client.active },
            initialize: { try await client.initialize($0) },
            anotherAppIsPlayingMusicUpdates: {
                NotificationCenter.default.notifications(named: AVAudioSession.silenceSecondaryAudioHintNotification)
                    .compactMap { notification in
                        guard let userInfo = notification.userInfo,
                              let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
                              let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue)
                        else { return .none }
                        return type
                    }
            },
            anotherAppIsPlayingMusic: { client.session.secondaryAudioShouldBeSilencedHint },
            anotherAppIsPlayingSound: { client.session.isOtherAudioPlaying })
    }
}

// MARK: Additional Data Structures
extension AudioSession {
    public struct Configuration: Sendable {
        public var category: AVAudioSession.Category
        public var mode: AVAudioSession.Mode
        public var options: AVAudioSession.CategoryOptions
        
        public init(category: AVAudioSession.Category, mode: AVAudioSession.Mode, options: AVAudioSession.CategoryOptions) {
            self.category = category
            self.mode = mode
            self.options = options
        }
        
        public static let `default`: Self = .init(
            category: .playAndRecord,
            mode: .measurement,
            options: [
                .allowBluetooth,
                .allowBluetoothA2DP,
                .overrideMutedMicrophoneInterruption,
                .mixWithOthers])
    }
    
    public enum Error: Swift.Error {
        case unavailable
    }

    actor Client {
        let session = AVAudioSession.sharedInstance()
        var active = false

        func initialize(_ config: Configuration) throws {
            guard session.availableCategories.contains(.playAndRecord),
                      session.availableModes.contains(.measurement)
            else { throw Error.unavailable }

            try session.setCategory(config.category, mode: config.mode, options: config.options)
            try session.setActive(true)
            active = true
        }
    }
}
