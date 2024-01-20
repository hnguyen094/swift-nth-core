//
//  AudioSession.swift
//  keepers-tech-demo
//
//  Created by hung on 1/19/24.
//

import Dependencies
import AVFoundation

extension DependencyValues {
    var audioSession: AudioSession {
        get { self[AudioSession.self] }
        set { self[AudioSession.self] = newValue }
    }
}

struct AudioSession {
    @Dependency(\.logger) private var logger
    private var session = AVAudioSession.sharedInstance()
    
    private(set) var isActive: Bool = false
    
    init() {
        logger.debug("Audio session starting.")
        guard session.availableCategories.contains(.playAndRecord),
                  session.availableModes.contains(.measurement)
        else {
            logger.error("Selected audio categories are not supported on this device.")
            return
        }
        
        do {
            try session.setCategory(
                        .playAndRecord,
                        mode: .measurement,
                        options: [
                            .allowBluetooth,
                            .allowBluetoothA2DP,
                            .overrideMutedMicrophoneInterruption,
                            .mixWithOthers])
            try session.setActive(true)
            isActive = true
        } catch {
            logger.error("Failed to start audio session \(error)")
        }
    }
    
    // might be bugged in Simulator only -- value is always false; seems working on iPad
    let anotherAppIsPlayingMusicUpdates: AsyncStream<AVAudioSession.SilenceSecondaryAudioHintType> =
        NotificationCenter.default.notifications(named: AVAudioSession.silenceSecondaryAudioHintNotification)
            .compactMap { notification in                
                guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
                    let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue)
                else { return .none }
                return type
            }.eraseToStream()
    
    var anotherAppIsPlayingMusic: Bool {
        session.secondaryAudioShouldBeSilencedHint
    }
    
    var anotherAppIsPlayingSound: Bool {
        session.isOtherAudioPlaying
    }
}

extension AudioSession: DependencyKey {
    static let liveValue: AudioSession = .init()
}
