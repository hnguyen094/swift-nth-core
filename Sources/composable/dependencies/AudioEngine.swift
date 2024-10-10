//
//  AudioEngine.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//

import Dependencies
import DependenciesMacros
@preconcurrency import AVFAudio

extension DependencyValues {
    public var audioEngine: AudioEngine {
        get { self[AudioEngine.self] }
        set { self[AudioEngine.self] = newValue }
    }
}

@DependencyClient
public struct AudioEngine: Sendable {
    public var installInputTap: @Sendable (@escaping @Sendable AVAudioNodeTapBlock) async throws -> Void
    public var validInputFormat: @Sendable () async -> AVAudioFormat? = { .none }
}

extension AudioEngine: DependencyKey {
    public static var liveValue: Self {
        let audioEngine: AVAudioEngine = .init()
        let inputBus = AVAudioNodeBus(0)
        let inputNode = audioEngine.inputNode

        return .init(
            installInputTap: { tapBlock in
                inputNode.removeTap(onBus: inputBus) // removes any previous tap
                inputNode.installTap(
                    onBus: inputBus,
                    bufferSize: 8192,
                    format: inputNode.inputFormat(forBus: inputBus),
                    block: tapBlock)
                try await startEngine()

                func startEngine() async throws {
                    @Dependency(\.audioSession) var audioSession
                    guard await audioSession.active(), !audioEngine.isRunning
                    else { return }
                    try audioEngine.start() // TODO: is there a scenario for calling stop?
                }
            },
            validInputFormat: {
                @Dependency(\.audioSession) var audioSession
                guard await audioSession.active() else { return .none }
                let format = inputNode.inputFormat(forBus: inputBus)
                return format.isValid() ? format : .none
            })
    }
}

extension AVAudioFormat {
    func isValid() -> Bool {
        channelCount != 0 && sampleRate != 0
    }
}
