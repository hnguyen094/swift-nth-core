//
//  AudioPlayerClient.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//
//  Audio System.

import Foundation
import Dependencies

extension DependencyValues {
    var audioPlayer: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}

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
