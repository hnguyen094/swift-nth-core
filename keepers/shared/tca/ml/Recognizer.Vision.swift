import ComposableArchitecture
import Vision

// TODO: this will be used to project raycasts onto the location so we can attempt to identify
// stability of objects in RK space. Objects do move, and so this should be considered.
// This source should be used a supplementary input due to its limited possible labels and false
// positive confidence, especially in low-light/unpredictable behavior.

// Maybe this implies that we need a layer to parse the raw ML data that we are receiving.
// NOTE: we could also use it to label meshes -- if the mesh is still there.

extension Recognizer {
    struct Vision: Reducer {
        @Dependency(\.machineLearning) var machineLearning
    }
}

extension Recognizer.Vision {
    struct State {
        var task: TaskState = .notStarted
        var request: RequestState = .idle
        var mlmodel: URL = .init(filePath: Bundle.main.path(forResource: "yolov8s", ofType: "mlmodel")!)
        
        var debugObservations: [Observation] = []
    }
    
    enum ModelID {
        case yolov8s
    }

    enum Action {
        case task
        case frameReceived(ARUpdates.FrameFacade)
        case observed([Observation])
        
        case requestChanged(RequestState) // TODO: handle dropping requests in MLClient
        case stateChanged(TaskState)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.task = .settingUp
                return .run {[url = state.mlmodel] send in
                    try await machineLearning.add(
                        id: ModelID.yolov8s, 
                        model: url, 
                        of: .vision(.classification))
                    let stream = try await machineLearning.vnStream(for: ModelID.yolov8s)
                    await send(.stateChanged(.running))
                    for await maybeResult in stream {
                        guard let result = maybeResult else { continue }
                        await send(.observed(result.compactMap(observationTransform(observation:))))
                    }
                } catch: { error, send in
                    print(error)
                    await send(.stateChanged(.failed(error)))
                }
            case .frameReceived(let frame):
                guard case .idle = state.request 
                else { return .none }
                state.request = .running
                return .run(priority: .utility) { send in
                    try await machineLearning.submit(image: .init(
                        image: frame.capturedImage,
                        depthData: frame.capturedDepthData, 
                        orientation: .init(frame.orientation)))
                    await send(.requestChanged(.idle))
                } catch: { error, send in
                    print(error)
                    await send(.requestChanged(.idle))
                }
            case .observed(let results):
                state.debugObservations = results.sorted { $0 > $1 }
                return .none
            case .requestChanged(let newState):
                state.request = newState
                return .none
            case .stateChanged(let newState):
                state.task = newState
                return .none
            }
        }
    }

    enum TaskState {
        case notStarted
        case settingUp
        case running
        case failed(Error)
    }
    
    enum RequestState {
        case idle
        case running
    }

    struct Observation: Comparable, Equatable, Identifiable {
        var id: UUID
        var label: String
        var confidence: VNConfidence
        var boundingBox: CGRect
        
        static func <(lhs: Self, rhs: Self) -> Bool {
            return lhs.confidence < rhs.confidence
        }
    }

    private func observationTransform(observation: VNObservation) -> Observation? {
        guard let recognizedObservation = observation as? VNRecognizedObjectObservation else {
            return .none
        }
        return .init(
            id: recognizedObservation.uuid,
            label: recognizedObservation.labels[0].identifier,
            confidence: recognizedObservation.confidence * recognizedObservation.labels[0].confidence, 
            boundingBox: recognizedObservation.boundingBox)
    }
}
