//
//  Resources.swift
//  keepers
//
//  Created by Hung on 9/25/23.
//

import Foundation
import Dependencies

extension DependencyValues {
    var resources: Resources {
        get { self[Resources.self] }
        set { self[Resources.self] = newValue }
    }
}

/// Provides a consistent place to manage all references to resources in the project. This allows for one point
/// of edit for named references to specific files.
/// There are better data structures to handle this, but for the time being we will use this and refactor
/// as necessary as the resources grow with the project. For example, this can instead load and cache the
/// necessary resources to avoid multiple requests of the same data.
struct Resources {
    /// The skybox name to be used with `RealityKit.EnvironmentResource`.
    let skybox: String
    
    /// The attribution text file to read & display when the user requests to see them.
    let attributions: String
}

extension Resources: DependencyKey {
    static var liveValue: Self {
        Resources(
            skybox: "kloppenheim_06_2k",
            attributions: "unimplementedattributions.txt"
        )
    }
}
