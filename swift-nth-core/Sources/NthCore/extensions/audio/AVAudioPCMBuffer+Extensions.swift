//
//  AVAudioPCMBuffer+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung.
//

import SoundAnalysis

public extension AVAudioPCMBuffer {
    // https://developer.apple.com/forums/thread/123926
    convenience init?(cmSampleBuffer sampleBuffer: CMSampleBuffer) {
        guard let audioFormat = sampleBuffer.getAudioFormat() else { 
            return nil
        }
        let frameCount = AVAudioFrameCount(sampleBuffer.numSamples)

        self.init(pcmFormat: audioFormat, frameCapacity: frameCount)
        frameLength = frameCount
        CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sampleBuffer, 
            at: 0, 
            frameCount: Int32(frameCount), 
            into: mutableAudioBufferList)
    }
}
