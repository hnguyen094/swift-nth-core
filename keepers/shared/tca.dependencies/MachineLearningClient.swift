import Foundation
import AVFoundation
import Dependencies

import Vision
import SoundAnalysis

// TODO: Break this file down
extension DependencyValues {
    var machineLearning: MachineLearningClient {
        get { self[MachineLearningClient.self] }
        set { self[MachineLearningClient.self] = newValue }
    }
}

actor MachineLearningClient {
    private var models: [AnyHashable: Compilable] = [:]

    private var streamAnalyzer: SNAudioStreamAnalyzer? = .none
    private var framePosition: AVAudioFramePosition = .zero
    
    func add(id: AnyHashable, model url: URL?, of backend: Backend) async throws {
        switch models[id] {
        case .some:
            throw MLError.existingID(id)
        case .none:
            let state: CompileState = switch url {
            case .some(let validURL):
                .uncompiled(validURL)
            case .none:
                .notRequired
            }
            switch backend {
            case .vision(let purpose):
                models[id] = VNModelData(state: state, purpose: purpose)
            case .soundAnalysis(let purpose):
                models[id] = SNModelData(state: state, purpose: purpose)
            }
            await compileMissing(for: backend)
        }
    }

    func vnStream(for id: AnyHashable) throws -> AsyncStream<[VNObservation]?> {
        guard let data = models[id] as? VNModelData else {
            throw MLError.unknownID(id)
        }
        return data.streamData.stream
    }

    func snStream(for id: AnyHashable) throws -> AsyncStream<[SNClassification]?> {
        guard let data = models[id] as? SNModelData else {
            throw MLError.unknownID(id)
        }
        return data.streamData.stream
    }

    func submit(image input: VNInput) async throws {
        let requests: [(AnyHashable, VNCoreMLRequest)] = models.compactMap { (id, data) in            
            guard case .compiled(let model) = data.state, let vnData = data as? VNModelData 
            else { return .none }
            if case .some(let request) = vnData.request {
                return (id, request)
            }
            do {
                let vnModel = try VNCoreMLModel(for: model)
                let request = VNCoreMLRequest(model: vnModel)
                request.imageCropAndScaleOption = vnData.cropAndScaleOption
                request.preferBackgroundProcessing = vnData.preferBackgroundProcessing
                return (id, VNCoreMLRequest(model: vnModel))
            } catch { // TODO: issue should be reported
                return .none
            }
        }
        let handler = if let depthData = input.depthData {
            VNImageRequestHandler(
                cvPixelBuffer: input.image, 
                depthData: depthData, 
                orientation: input.orientation)
        } else {
            VNImageRequestHandler(
                cvPixelBuffer: input.image,
                orientation: input.orientation)
        }
        try handler.perform(requests.map( { $0.1 }))

        for (id, request) in requests {
            (models[id] as? VNModelData)?.streamData.continuation?.yield(request.results)
        }
    }

    // TODO: fix not throttling due to actor being synchronous anyway
    func submit(sound input: SNInput) async throws {
        if case .none = streamAnalyzer, let audioFormat = input.sound.getAudioFormat() {
            streamAnalyzer = SNAudioStreamAnalyzer(format: audioFormat)
        }

        let newRequests: [(AnyHashable, SNClassifySoundRequest)] = models.compactMap { (id, data) in
            guard let snData = data as? SNModelData, case .none = snData.request else { 
                return .none
            }
            do {
                switch data.state {
                case .compiled(let model):
                    let request = try SNClassifySoundRequest(mlModel: model)
                    if let seconds = snData.targetWindowInSeconds,
                        let duration = request.getWindowDuration(preferredDuration: seconds) {
                        request.windowDuration = duration
                    }
                    if let overlapFactor = snData.overlapFactor {
                        request.overlapFactor = overlapFactor
                    }
                    snData.request = request
                    return (id, request)
                case .notRequired where id is SNClassifierIdentifier:
                    let request = try SNClassifySoundRequest(classifierIdentifier: id as! SNClassifierIdentifier)
                    if let seconds = snData.targetWindowInSeconds,
                       let duration = request.getWindowDuration(preferredDuration: seconds) {
                        request.windowDuration = duration
                    }
                    if let overlapFactor = snData.overlapFactor {
                        request.overlapFactor = overlapFactor
                    }
                    snData.request = request
                    return (id, request)
                case .notRequired, .uncompiled, .error:
                    return .none
                }
            } catch { // likely to be a non-sound analysis model
                print("error: \(error)")
                return .none
            }
        }

        for (id, request) in newRequests where (models[id] as? SNModelData)?.observer is SNObserver {
            guard let observer = (models[id] as? SNModelData)?.observer else { continue }
            do {
                try streamAnalyzer?.add(request, withObserver: observer)
            } catch {
                print("error: failed to add request to stream analyzer") // TODO: error handle
            }
        }
        guard let buffer = AVAudioPCMBuffer(cmSampleBuffer: input.sound)
        else { return }
        
        streamAnalyzer?.analyze(buffer, atAudioFramePosition: framePosition)
        framePosition = framePosition.advanced(by: Int(buffer.frameLength))
    }
}

extension MachineLearningClient: DependencyKey {
    static let liveValue: MachineLearningClient = .init()
    
    enum MLError: Error {
        case unknownID(AnyHashable)
        case existingID(AnyHashable)
    }
    
    enum Backend {
        case vision(Purpose)
        case soundAnalysis(Purpose)

        enum Purpose {
            case classification
            /// Used specifically to be a placeholder value. It has no meaning.
            case internalUseOnly
        }
    }
    
    struct VNInput {
        var image: CVPixelBuffer
        var depthData: AVDepthData? = .none
        var orientation: CGImagePropertyOrientation
    }
    
    struct SNInput {
        var sound: CMSampleBuffer
    }
    
    /// An observer that receives results from a classify sound request.
    fileprivate class SNObserver: NSObject, SNResultsObserving {        
        var purpose: Backend.Purpose
        var continuation: AsyncStream<[SNClassification]?>.Continuation
        
        init(for purpose: Backend.Purpose, continuation: AsyncStream<[SNClassification]?>.Continuation) {
            self.purpose = purpose
            self.continuation = continuation
        }
        
        /// Notifies the observer when a request generates a prediction.
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult else { return }
            
            continuation.yield(result.classifications
                .filter({ $0.confidence > 0.25 }))
        }
        
        /// Notifies the observer when a request generates an error.
        func request(_ request: SNRequest, didFailWithError error: Error) {
            print("The analysis failed: \(error.localizedDescription)")
        }
        
        /// Notifies the observer when a request is complete.
        func requestDidComplete(_ request: SNRequest) {
            print("The request completed successfully!")
        }
    }
}

extension MachineLearningClient {
    fileprivate class VNModelData: Compilable {
        var state: CompileState
        var streamData: StreamData<[VNObservation]?> = .init()
        var purpose: Backend.Purpose
        
        var request: VNCoreMLRequest? = .none
        var cropAndScaleOption: VNImageCropAndScaleOption = .centerCrop
        var preferBackgroundProcessing: Bool = true
        
        init(state: CompileState, purpose: Backend.Purpose) {
            self.state = state
            self.purpose = purpose
        }
    }
    
    fileprivate class SNModelData: Compilable {
        var state: CompileState
        var streamData: StreamData<[SNClassification]?> = .init()
        var purpose: Backend.Purpose
        
        var observer: SNObserver
        var request: SNRequest? = .none
        var targetWindowInSeconds: Double? = 2
        var overlapFactor: Double? = .none
        
        init(state: CompileState, purpose: Backend.Purpose) {
            self.state = state
            self.purpose = purpose
            self.observer = .init(for: purpose, continuation: streamData.continuation!)
        }
    }
    
    fileprivate struct StreamData<Result> {
        var stream: AsyncStream<Result> = .never
        var continuation: AsyncStream<Result>.Continuation? = .none
        
        init() {
            stream = AsyncStream { continuation in
                self.continuation = continuation
            }
        }
    }
    
    fileprivate func compileMissing(for backend: Backend) async {
        let compiled = await withTaskGroup(of: (AnyHashable, Result<URL, Error>).self) { group in
            var result: [AnyHashable: Result<URL, Error>] = [:]
            
            for (id, model) in models {                
                switch (backend, model) {
                case (.vision, _) as (Backend, VNModelData), (.soundAnalysis, _) as (Backend, SNModelData):
                    switch model.state {
                    case .uncompiled(let url):
                        group.addTask {
                            do {
                                return (id, .success(try await MLModel.compileModel(at: url)))
                            } catch {
                                return (id, .failure(error))
                            }
                        }
                    case .compiled, .notRequired, .error:
                        break
                    }
                default:
                    break
                }
            }
            
            for await (id, compiled) in group {
                result[id] = compiled
            }
            return result
        }
        for (id, result) in compiled {
            do {
                models[id]!.state = switch result {
                case .success(let url):
                        .compiled(try MLModel(contentsOf: url))
                case .failure(let error):
                        .error(error)
                }
            } catch {
                models[id]!.state = .error(error)
            }
        }
        //        return compiled
        //            .filter { if case .success = $0.value { true } else { false } }
        //            .map { $0.key }
    }
}

fileprivate protocol Compilable {
    var state: CompileState {get set}
}

fileprivate enum CompileState {
    case uncompiled(URL)
    case compiled(MLModel)
    case notRequired
    case error(Error)
}
