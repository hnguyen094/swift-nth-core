//
//  WorldTrackerClient.swift
//  keepers-together
//
//  Created by Hung on 11/30/23.
//

import Foundation
import ARKit
import Dependencies

extension DependencyValues {
    var worldTracker: WorldTrackerClient {
        get { self[WorldTrackerClient.self] }
        set { self[WorldTrackerClient.self] = newValue }
    }
}

struct WorldTrackerClient {
    @Dependency(\.logger) var logger
    
    let session: ARKitSession
    let worldInfo: WorldTrackingProvider
    
    init() {
        session = ARKitSession()
        worldInfo = WorldTrackingProvider()
    }
    
    async func run() {
        let results = await session.requestAuthorization(for: [.worldSensing])
        if results[.worldSensing] == .allowed {
            do {
                try await session.run([worldInfo])
            } catch {
                logger.error("Failed to start ARKitSession (\(error))")
            }
        }
    }
    
    async func beginAnchorUpdates() {
        for await update in worldInfo.anchorUpdates {
             switch update.event {
             case .added, .updated:
                 // Update the app's understanding of this world anchor.
                 print("Anchor position updated.")
             case .removed:
                 // Remove content related to this anchor.
                 print("Anchor position now unknown.")
         }
    }
}

extension WorldTrackerClient: DependencyKey {
    static var liveValue: Self {
        WorldTrackerClient()
    }
}
