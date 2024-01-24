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

    var worldSensingAuthorized: Bool = false
    var handTrackingAuthorized: Bool = false
    
    private var sessionStarted = false
    
    func attemptStartARKitSession() async {
        guard !sessionStarted else { return }
        
        let authorizations = await session.requestAuthorization(for: [.handTracking, .worldSensing])
        worldSensingAuthorized = authorizations[.worldSensing] == .allowed
        handTrackingAuthorized = authorizations[.handTracking] == .allowed
        
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
    
    struct AvailableSurfaces: Equatable {
        private(set) var classifications: [PlaneAnchor.Classification: Set<PlaneAnchor.ID>] = [:]
        private var reversedClassifications: [PlaneAnchor.ID: PlaneAnchor.Classification] = [:]
        
        mutating func handleUpdate(_ update: AnchorUpdate<PlaneAnchor>) {
            let anchorID = update.anchor.id
            let classification = update.anchor.classification
            switch update.event {
            case .added:
                classifications[classification, default: .init()].insert(anchorID)
                reversedClassifications[anchorID] = classification
            case .updated:
                if let oldClassification = reversedClassifications[anchorID],
                   classification != oldClassification
                {
                    classifications[oldClassification]?.remove(anchorID)
                    if classifications[oldClassification]?.isEmpty ?? false {
                        classifications.removeValue(forKey: oldClassification)
                    }
                }
                classifications[classification, default: .init()].insert(anchorID)
                reversedClassifications[anchorID] = classification
            case .removed:
                classifications[classification]?.remove(anchorID)
                if classifications[classification]?.isEmpty ?? false {
                    classifications.removeValue(forKey: classification)
                }
                reversedClassifications.removeValue(forKey: anchorID)
            }
        }
    }
    
    struct AvailableMeshes: Equatable {
        private(set) var classifications: [MeshAnchor.MeshClassification : Set<MeshAnchor.ID>] = [:]
        private var reversedClassifications: [MeshAnchor.ID: Set<MeshAnchor.MeshClassification>] = [:]
        
        mutating func handleUpdate(_ update: AnchorUpdate<MeshAnchor>) {
            let anchorID = update.anchor.id
            switch update.event {
            case .added:
                let values = update.anchor.geometry.allClassifications()
                let classificationSet = Set(values)
                
                reversedClassifications[anchorID] = classificationSet
                
                classificationSet.forEach { classification in
                    classifications[classification, default: .init()].insert(anchorID)
                }
            case .updated:
                let values = update.anchor.geometry.allClassifications()
                let classificationSet = Set(values)
                
                let previousClassifications = reversedClassifications[anchorID] ?? .init()
                
                let toAdd = classificationSet.subtracting(previousClassifications)
                let toRemove = previousClassifications.subtracting(classificationSet)
                
                toAdd.forEach { classification in
                    classifications[classification, default: .init()].insert(anchorID)
                }
                
                toRemove.forEach { classification in
                    classifications[classification]?.remove(anchorID)
                    if classifications[classification]?.isEmpty ?? false {
                        classifications.removeValue(forKey: classification)
                    }
                }
                reversedClassifications[anchorID] = classificationSet
            case .removed:
                let values = update.anchor.geometry.allClassifications()
                let classificationSet = Set(values)
                
                reversedClassifications.removeValue(forKey: anchorID)
                
                classificationSet.forEach { classification in
                    classifications[classification]?.remove(anchorID)
                    if classifications[classification]?.isEmpty ?? false {
                        classifications.removeValue(forKey: classification)
                    }
                }
            }
        }
    }
}
