//
//  SoundAnalysisClient.swift
//  keepers-tech-demo
//
//  Created by hung on 1/19/24.
//

import Dependencies
import SoundAnalysis

extension DependencyValues {
    var audioEngine: AVAudioEngine {
        get { self[AudioEngineKey.self] }
        set { self[AudioEngineKey.self] = newValue }
    }
    
    var soundAnalysis: SoundAnalysisClient {
        get { self[SoundAnalysisClient.self] }
        set { self[SoundAnalysisClient.self] = newValue }
    }

    private enum AudioEngineKey: DependencyKey {
        static let liveValue: AVAudioEngine = .init()
    }
}

struct SoundAnalysisClient {
    var streamAnalyzer: SNAudioStreamAnalyzer
    
    fileprivate let observer: SNObserver = SNObserver()
    fileprivate static let analysisQueue = DispatchQueue(label: "com.nth.soundanalysis")

    init() {
        @Dependency(\.audioEngine) var audioEngine
        @Dependency(\.logger) var logger

        let inputBus = AVAudioNodeBus(0)
        let inputFormat = audioEngine.inputNode.inputFormat(forBus: inputBus)
        streamAnalyzer = .init(format: inputFormat)

        do {
            try audioEngine.start()
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            if let windowDuration = request.getWindowDuration(preferredDuration: 2) {
                request.windowDuration = windowDuration
            }
            try streamAnalyzer.add(request, withObserver: observer)

            audioEngine.inputNode.installTap(
                onBus: inputBus,
                bufferSize: 8192,
                format: inputFormat
            ) { [streamAnalyzer] buffer, time in
                Self.analysisQueue.async {
                    streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                }
            }
        } catch {
            logger.error("Failed to initialize sound analysis: \(error)")
        }
    }

    func classificationUpdates() -> AsyncStream<Result> {
        AsyncStream { continuation in
            observer.continuation = continuation
        }
    }
}

extension SoundAnalysisClient: DependencyKey {
    static let liveValue: SoundAnalysisClient = .init()
    
    /// An observer that receives results from a classify sound request.
    fileprivate class SNObserver: NSObject, SNResultsObserving {
        @Dependency(\.logger) var logger

        var continuation: AsyncStream<Result>.Continuation? = .none
        
        init(continuation: AsyncStream<Result>.Continuation? = .none) {
            self.continuation = continuation
        }
        
        /// Notifies the observer when a request generates a prediction.
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult else { return }
            
            continuation?.yield(.init(
                timeRange: result.timeRange.start.seconds..<result.timeRange.end.seconds,
                classifications: result.classifications
                    .filter({ $0.confidence > 0.25 })
                    .map({ Classification(from: $0) })))
        }
        
        /// Notifies the observer when a request generates an error.
        func request(_ request: SNRequest, didFailWithError error: Error) {
            logger.error("The analysis failed: \(error.localizedDescription)")
        }
        
        /// Notifies the observer when a request is complete.
        func requestDidComplete(_ request: SNRequest) {
            logger.debug("The request completed successfully!")
        }
    }
    
    struct Result: Equatable {
        var timeRange: Range<Double>
        var classifications: [Classification]
    }
    
    struct Classification: Equatable, Identifiable {
        var id: UUID
        var label: SoundType
        var confidence: Double
        
        init(from classification: SNClassification) {
            @Dependency(\.uuid) var uuid

            id = uuid()
            label = .init(rawValue: classification.identifier) ?? .unknown
            confidence = classification.confidence
        }
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }
}