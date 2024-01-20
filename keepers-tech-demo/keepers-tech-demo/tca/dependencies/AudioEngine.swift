//
//  AudioEngine.swift
//  keepers-tech-demo
//
//  Created by hung on 1/20/24.
//

import Dependencies
import AVFAudio

extension DependencyValues {
    var audioEngine: AudioEngine {
        get { self[AudioEngine.self] }
        set { self[AudioEngine.self] = newValue }
    }
}

struct AudioEngine {
    @Dependency(\.logger) var logger

    private let audioEngine: AVAudioEngine = .init()
    private let inputBus = AVAudioNodeBus(0)
    private let inputNode: AVAudioInputNode
    init() {
        inputNode = audioEngine.inputNode // required to start engine
    }

    func inputFormat() -> AVAudioFormat {
        inputNode.inputFormat(forBus: inputBus)
    }

    func installInputTap(block tapBlock: @escaping AVAudioNodeTapBlock) {
        let inputFormat = inputNode.inputFormat(forBus: inputBus)

        inputNode.installTap(
            onBus: inputBus,
            bufferSize: 8192,
            format: inputFormat,
            block: tapBlock)
        startEngine()
    }
    
    private func startEngine() {
        guard !audioEngine.isRunning else { return }

        do {
            try audioEngine.start()
        } catch {
            logger.error("Failed to start audioEngine")
        }
    }
}

extension AudioEngine: DependencyKey {
    static let liveValue: AudioEngine = .init()
}
