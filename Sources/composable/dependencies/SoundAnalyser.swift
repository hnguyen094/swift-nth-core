//
//  SoundAnalyser.swift
//  keepers-tech-demo
//
//  Created by hung on 1/19/24.
//

import Dependencies
import DependenciesMacros
import SoundAnalysis
import NthCommon

extension DependencyValues {
    public var soundAnalysis: SoundAnalyser {
        get { self[SoundAnalyser.self] }
        set { self[SoundAnalyser.self] = newValue }
    }
}

@DependencyClient
public struct SoundAnalyser {
    public var initialize: (Configuration) throws -> Void
    public var classificationUpdates: () -> AsyncStream<RequestResult> = { .never }
}

extension SoundAnalyser: DependencyKey {
    public static let testValue: Self = .init()
    public static let previewValue: Self = .init()
    public static var liveValue: Self {
        let observer = SNObserver()
        let analysisQueue = DispatchQueue(label: "com.nth.soundanalysis", qos: .userInitiated)
        return .init(
            initialize: { config in
                @Dependency(\.audioEngine) var audioEngine
                guard let inputFormat = audioEngine.validInputFormat() else {
                    throw Error.invalidFormat
                }
                observer.minimumThreshold = config.minimumConfidenceThreshold
                let streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
                let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
                if let windowDuration = request.getWindowDuration(preferredDuration: config.preferredWindowDuration) {
                    request.windowDuration = windowDuration
                }
                if let overlapFactor = config.preferredOverlapFactor {
                    request.overlapFactor = overlapFactor
                }
                try streamAnalyzer.add(request, withObserver: observer)
                try audioEngine.installInputTap { buffer, time in
                    analysisQueue.async {
                        streamAnalyzer.analyze(buffer, atAudioFramePosition: time.sampleTime)
                    }
                }
            },
            classificationUpdates: { .init { continuation in
                @Dependency(\.uuid) var uuid
                let continuationContainer = IdentifiedContinuation(id: uuid(), continuation: continuation)
                observer.continuations.insert(continuationContainer)

                continuation.onTermination = { status in
                    observer.continuations.remove(continuationContainer)
                }
            }}
        )
    }
}

extension SoundAnalyser {
    public struct Configuration {
        public let preferredWindowDuration: Double = 2
        public let preferredOverlapFactor: Double? = .none
        public let minimumConfidenceThreshold: Double = 0.1
        
        public static let `default`: Self = .init()
    }
    
    public enum Error: Swift.Error {
        case invalidFormat
    }
    
    public enum RequestResult {
        case result(Result)
        case error(Swift.Error)
    }
    
    struct IdentifiedContinuation: Hashable {
        let id: UUID
        let continuation: AsyncStream<RequestResult>.Continuation
        
        static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    public struct Result: Equatable, CustomDebugStringConvertible {
        public var timeRange: Range<Double>
        public var classifications: [Classification]
        
        public var debugDescription: String {
            var msg = "\(self.timeRange):\n"
            var wasHigh = true
            for classification in self.classifications {
                if wasHigh && classification.confidence < 0.5 {
                    msg += "\n"
                    wasHigh = false
                }
                let confidence = String(format: "%.2f", classification.confidence)
                msg += "\(confidence): \(classification.label.rawValue)\n"
            }
            return msg
        }
    }
    
    public struct Classification: Equatable, Identifiable {
        public var id: UUID
        public var label: SoundAnalyser.SoundType
        public var confidence: Double
        
        init(from classification: SNClassification) {
            @Dependency(\.uuid) var uuid

            id = uuid()
            label = .init(rawValue: classification.identifier) ?? .unknown
            confidence = classification.confidence
        }
        
        public static func ==(lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }
    }

    /// An observer that receives results from a classify sound request.
    fileprivate class SNObserver: NSObject, SNResultsObserving {
        var continuations: Set<IdentifiedContinuation> = .init()
        var minimumThreshold: Double = 0

        /// Notifies the observer when a request generates a prediction.
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult else { return }

            let requestResult: RequestResult = .result(.init(
                timeRange: result.timeRange.start.seconds..<result.timeRange.end.seconds,
                classifications: result.classifications
                    .filter({ $0.confidence > minimumThreshold })
                    .map({ Classification(from: $0) })))

            for container in continuations {
                container.continuation.yield(requestResult)
            }
        }

        /// Notifies the observer when a request generates an error.
        func request(_ request: SNRequest, didFailWithError error: Swift.Error) {
            for container in continuations {
                container.continuation.yield(.error(error))
            }
        }

        /// Notifies the observer when a request is complete.
        func requestDidComplete(_ request: SNRequest) {
            for container in continuations {
                container.continuation.finish()
            }
        }
    }
}
