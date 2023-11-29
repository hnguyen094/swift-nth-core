//
//  AudioSettings.swift
//  keepers
//
//  Created by Hung on 9/9/23.
//

import ComposableArchitecture

@Reducer
struct AudioSettings: Reducer {
    typealias Category = AudioPlayerClient.AudioCategory
    
    @Dependency(\.audioPlayer) var player
    @Dependency(\.logger) var logger
    @Dependency(\.mainQueue) var mainQueue
    
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
        case changeVolumeUpdateValue(Float, Category)
        case requestVolumeChange(Category)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .changeVolumeUpdateValue(let volume, let category):
            state.volumes[category] = volume
            return .none
        case .requestVolumeChange(let category):
            return .run { [volume = state.volumes[category]!] send in
                await player.setVolume(volume, category)
                logger.info("""
                        Volume of category [\(String(describing: category))] \
                        set to \(volume, attributes: "%.2f").
                        """)
            }
        }
    }
}
