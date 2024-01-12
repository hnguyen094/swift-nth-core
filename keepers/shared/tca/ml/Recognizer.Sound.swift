import ComposableArchitecture
import SoundAnalysis

extension Recognizer {
    struct Sound: Reducer {
        @Dependency(\.machineLearning) var machineLearning
        @Dependency(\.uuid) var uuid
    }
}

extension Recognizer.Sound {
    struct State {
        var modelIdentifier = SNClassifierIdentifier.version1
        var task: TaskState = .notStarted
        var debugClassifications: [Classification] = []
    }
    
    enum TaskState {
        case notStarted
        case settingUp
        case running
        case failed(Error)
    }
    
    enum Action {
        case task
        case sampleBufferReceived(CMSampleBuffer)
        case observed([Classification])
        
        case stateChanged(TaskState)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.task = .settingUp
                return .run(priority: .utility) {[id = state.modelIdentifier] send in
                    try await machineLearning.add(
                        id: id, 
                        model: .none, 
                        of: .soundAnalysis(.classification))
                    let stream = try await machineLearning.snStream(for: id)
                    await send(.stateChanged(.running))
                    for await maybeResult in stream {
                        guard let result = maybeResult else { continue }
                        await send(.observed(result.map(classificationTransform(classification:))))
                    }
                } catch: { error, send in
                    print(error)
                    await send(.stateChanged(.failed(error)))
                }
            case .stateChanged(let newState):
                state.task = newState
                return .none
            case .sampleBufferReceived(let buffer):
                return .run(priority: .utility) {send in
                    try await machineLearning.submit(sound: .init(sound: buffer))
                } catch: { error, send in
                    print(error)
                }
            case .observed(let results):
                state.debugClassifications = results
                return .none
            }
        }
    }
    
    private func classificationTransform(classification: SNClassification) -> Classification {
        .init(
            id: uuid(), 
            label: .init(rawValue: classification.identifier) ?? .unknown, 
            confidence: classification.confidence)
    }
    
    struct Classification: Equatable, Identifiable {
        var id: UUID
        var label: SoundType
        var confidence: Double
    }
}
