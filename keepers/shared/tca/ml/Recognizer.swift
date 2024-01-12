import ComposableArchitecture

struct Recognizer: Reducer {
    struct State {
        var vision: Vision.State = .init()
        var sound: Sound.State = .init()
    }
    
    enum Action {
        case start
        case processARUpdates(ARUpdates.Event)
        case updated(Observation)

        case vision(Vision.Action)
        case sound(Sound.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.vision, action: /Action.vision) {
            Vision()
        }
        Scope(state: \State.sound, action: /Action.sound) {
            Sound()
        }
        Reduce { state, action in
            switch action {
            case .start:
                return EffectOf<Self>.merge(
                    .send(.vision(.task)),
                    .send(.sound(.task))
                )
            case .processARUpdates(let event):
                switch event {
                case .frameUpdated(let frame):
                    return .send(.vision(.frameReceived(frame)))
                case .audioSampleBufferOutputted(let sampleBuffer):
                    return .send(.sound(.sampleBufferReceived(sampleBuffer)))
                default:
                    return .none
                }
            case .vision(.observed(let observations)):
                return .send(.updated(.visual(observations)))
            case .sound(.observed(let observations)):
                return .send(.updated(.auditory(observations)))
            case .vision, .sound, .updated:
                return .none
            }  
        }
    }

    enum Observation {
        case visual([Vision.Observation])
        case auditory([Sound.Classification])
    }
}
