//
//  WorldTrackerClient.swift
//  keepers-together
//
//  Created by Hung on 11/30/23.
//

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
    
    let session = ARKitSession()
    let worldInfo = WorldTrackingProvider()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal])
    let meshData = SceneReconstructionProvider(modes: [.classification])
    
    var planes : Dictionary<UUID, PlaneAnchor> = [:]
    var meshes : Dictionary<UUID, MeshAnchor> = [:]
    
    func run() async {
        print("running")
        do {
            try await session.run([worldInfo, planeData, meshData])
        } catch {
            logger.error("Failed to start ARKitSession (\(error))")
        }

//        let results = await session.requestAuthorization(for: [.worldSensing])
//        switch results[.worldSensing] {
//        case .allowed:
//            do {
//                try await session.run([worldInfo])
//            } catch {
//                logger.error("Failed to start ARKitSession (\(error))")
//            }
//        case .denied, .notDetermined:
//            fallthrough
//        default:
//            logger.error("World sensing authorization missing.")
//        }
    }
    
    func beginWorldAnchorUpdates() async {
        for await update in worldInfo.anchorUpdates {
            switch update.event {
            case .added, .updated:
                // Update the app's understanding of this world anchor.
                logger.debug("World anchor[\(update.anchor.originFromAnchorTransform.debugDescription)] position updated.")
            case .removed:
                // Remove content related to this anchor.
                logger.debug("World anchor[\(update.anchor.originFromAnchorTransform.debugDescription)] position now unknown.")
            }
         }
    }
    
    func beginPlaneAnchorUpdates() async {
        for await update in planeData.anchorUpdates {
            switch update.event {
            case .added, .updated:
                // Update the app's understanding of this plane anchor.
                logger.debug("Plane anchor[\(update.anchor.classification.description)] position updated.")
            case .removed:
                // Remove content related to this anchor.
                logger.debug("Plane anchor[\(update.anchor.classification.description)] position now unknown.\n")
            }
        }
    }
    
    func beginMeshAnchorUpdates() async {
        for await update in meshData.anchorUpdates {
            switch update.event {
            case .added, .updated:
                // Update the app's understanding of this plane anchor.
                logger.debug("Mesh anchor[\(update.anchor.geometry.description)] position updated.")
            case .removed:
                // Remove content related to this anchor.
                logger.debug("Mesh anchor[\(update.anchor.geometry.description)] position now unknown.\n")
            }
        }
    }
}

extension WorldTrackerClient: DependencyKey {
    static var liveValue: Self {
        WorldTrackerClient()
    }
}
