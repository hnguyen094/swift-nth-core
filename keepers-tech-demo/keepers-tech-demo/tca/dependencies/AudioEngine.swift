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
    @Dependency(\.audioSession) var audioSession
    
    private let audioEngine: AVAudioEngine = .init()
    private let inputBus = AVAudioNodeBus(0)
    private let inputNode: AVAudioInputNode
    
    var validInputFormat: AVAudioFormat? {
        guard audioSession.isActive else { return .none } // necessary to initialize audioSession
        let format = inputNode.inputFormat(forBus: inputBus)
        return format.isValid() ? format : .none
    }
    
    init() {
        inputNode = audioEngine.inputNode
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

extension AVAudioFormat {
    func isValid() -> Bool {
        channelCount != 0 && sampleRate != 0
    }
}
