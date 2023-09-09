//
//  AudioSettings.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import ComposableArchitecture

struct AudioSettings: Reducer {
    typealias Category = AudioPlayerClient.AudioCategory
    
    @Dependency(\.audioPlayer.setVolume) var setVolume
    @Dependency(\.logger) var logger

    struct State {
        var volumes: Dictionary<Category, Float>
    }
    
    enum Action {
        case requestVolume(Float, Category)
        case updateVolume(Float, Category)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .requestVolume(let volume, let type):
            return .none
            return .run { send in
                await setVolume(volume, type)
                await send(.updateVolume(volume, type))
            } catch: { error, _ in
                logger.error("Caught error while trying to set volume. [\(error)]")
            }
        case .updateVolume(let volume, let type):
            logger.info("Volume of category [\(String(describing: type))] set to \(volume, attributes: "%.2f").")
            state.volumes[type] = volume
            return .none
        }
    }
}
