//
//  ARKitSessionManager.swift
//  keepers-tech-demo
//
//  Created by hung on 1/15/24.
//

import ARKit
import Dependencies

extension DependencyValues {
    var arkitSessionManager: ARKitSessionManager {
        get { self[ARKitSessionManager.self] }
        set { self[ARKitSessionManager.self] = newValue }
    }

}

@MainActor
class ARKitSessionManager {
    @Dependency(\.logger) private var logger

    var session: ARKitSession = .init()

    var planeData: PlaneDetectionProvider? = .none
    var sceneReconstructionData: SceneReconstructionProvider? = .none
    var handData: HandTrackingProvider? = .none
    var worldTrackingData: WorldTrackingProvider? = .none

    private var sessionStarted = false
    
    func attemptStartARKitSession() async {
        guard !sessionStarted else { return }
        
        let authorizations = await session.requestAuthorization(for: [.handTracking, .worldSensing])
        logger.debug("worldSensing auth: \(authorizations[.worldSensing].debugDescription)")
        logger.debug("handTracking auth: \(authorizations[.handTracking].debugDescription)")

        if PlaneDetectionProvider.isSupportedAndAuthorized(authorizations) {
            planeData = planeData ?? PlaneDetectionProvider()
        }
        if HandTrackingProvider.isSupportedAndAuthorized(authorizations) {
            handData = handData ?? HandTrackingProvider()
        }
        if WorldTrackingProvider.isSupportedAndAuthorized(authorizations) {
            worldTrackingData = worldTrackingData ?? WorldTrackingProvider()
        }
        if SceneReconstructionProvider.isSupportedAndAuthorized(authorizations) {
            sceneReconstructionData = sceneReconstructionData ?? SceneReconstructionProvider(modes: [.classification])
        }

        do {
            let validProviders: [DataProvider] = [
                planeData,
                sceneReconstructionData,
                handData,
                worldTrackingData
            ].compact()
            try await session.run(validProviders)
            sessionStarted = true
        } catch {
            logger.critical("Failed to start ARKit session: \(error)")
            sessionStarted = false
        }
    }
}

extension ARKitSessionManager : DependencyKey {
    static let liveValue: ARKitSessionManager = .init()
}
