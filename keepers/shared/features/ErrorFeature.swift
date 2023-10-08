//
//  ErrorFeature.swift
//  keepers
//
//  Created by Hung on 10/7/23.
//

import ComposableArchitecture

struct ErrorFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    struct State: Equatable {
        static func == (lhs: ErrorFeature.State, rhs: ErrorFeature.State) -> Bool {
            lhs.error.localizedDescription < rhs.error.localizedDescription
        }
        
        let error: Error
    }
    
    enum Action {
        case dismiss
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .dismiss:
            .run {_ in
                await dismiss()
            }
        }
    }
    
    struct SampleError : Error { }
}
