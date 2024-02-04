//
//  AudioEngine.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//

import Dependencies
import DependenciesMacros
import AVFAudio

extension DependencyValues {
    public var audioEngine: AudioEngine {
        get { self[AudioEngine.self] }
        set { self[AudioEngine.self] = newValue }
    }
}

@DependencyClient
public struct AudioEngine {
    public var installInputTap: (_ block: @escaping AVAudioNodeTapBlock) throws -> Void
    public var validInputFormat: () -> AVAudioFormat? = { .none }
}

extension AudioEngine: DependencyKey {
    public static let testValue: Self = .init()
    public static let previewValue: Self = .init()
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
                try startEngine()

                func startEngine() throws {
                    @Dependency(\.audioSession) var audioSession
                    guard audioSession.active(), !audioEngine.isRunning
                    else { return }
                    try audioEngine.start() // TODO: is there a scenario for calling stop?
                }
            },
            validInputFormat: {
                @Dependency(\.audioSession) var audioSession
                guard audioSession.active() else { return .none }
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
