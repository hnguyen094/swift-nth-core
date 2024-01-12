import SwiftUI
import SoundAnalysis

// Similar to CVImageBuffer+Sendable
extension CMSampleBuffer: @unchecked Sendable {
    func getAudioFormat() -> AVAudioFormat? {
        guard let formatDescription = self.formatDescription else {
            return nil
        }
        return AVAudioFormat(cmAudioFormatDescription: formatDescription)
    }
}
