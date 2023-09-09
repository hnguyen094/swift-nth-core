//
//  AudioSettings.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import ComposableArchitecture

struct AudioSettings: Reducer {
    typealias Category = AudioPlayerClient.AudioCategory
    
    @Dependency(\.audioPlayer) var player
    @Dependency(\.logger) var logger

    struct State: Equatable {
        var volumes: Dictionary<Category, Float> = [:]
        
        init() {
            @Dependency(\.audioPlayer) var player

            for category in Category.allCases {
                volumes[category] = player.getVolume(category)
            }
        }
    }
    
    enum Action {
        case requestVolumeUpdate(Float, Category)
        case volumeUpdateSuccess(Float, Category)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .requestVolumeUpdate(let volume, let type):
            if (state.volumes[type] == volume) {
                return .none
            }
            
            return .run { send in
                await player.setVolume(volume, type)
                await send(.volumeUpdateSuccess(volume, type))
            } catch: { error, _ in
                logger.error("Caught error while trying to set volume. [\(error)]")
            }
        case .volumeUpdateSuccess(let volume, let type):
            logger.info("Volume of category [\(String(describing: type))] set to \(volume, attributes: "%.2f").")
            state.volumes[type] = volume
            return .none
        }
    }
}
