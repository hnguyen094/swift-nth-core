//
//  CMSampleBufferExtensions.swift
//  keepers-tech-demo
//
//  Created by hung.
//

import SwiftUI
import SoundAnalysis

// Similar to CVImageBuffer+Sendable
extension CMSampleBuffer: @unchecked @retroactive Sendable {
    public func getAudioFormat() -> AVAudioFormat? {
        guard let formatDescription = self.formatDescription else {
            return nil
        }
        return AVAudioFormat(cmAudioFormatDescription: formatDescription)
    }
}
