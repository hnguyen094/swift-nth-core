import SoundAnalysis

extension SNClassifySoundRequest {
    func getWindowDuration(preferredDuration seconds: Double) -> CMTime? {
        let target = CMTime(seconds: seconds, preferredTimescale: 1000)
        
        return switch self.windowDurationConstraint {
        case .durationRange(let range):
            range.containsTime(target) 
            ? target 
            : .init( // inaccurate due to Double rounding
                seconds: range.start.seconds + (range.duration.seconds / 2),
                preferredTimescale: range.start.timescale)
        case .enumeratedDurations(let validWindows):
            validWindows.contains(where: { $0 == target} )
            ? target
            : validWindows[validWindows.count / 2]
        @unknown default:
                .none
        }
    }
}
