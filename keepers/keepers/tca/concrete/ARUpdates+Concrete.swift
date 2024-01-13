//
//  ARUpdates+Concrete.swift
//  keepers
//
//  Created by hung on 1/12/24.
//
import ARKit
import RealityKit

extension ARUpdates.AnchorFacade {
    init(_ anchor : ARAnchor) {
        switch anchor {
        case let plane as ARPlaneAnchor:
            // TODO: add plane.planeExtent's details and plane.center
            self = .plane(.init(
                center: plane.center,
                classification: .init(plane.classification)
            ))
        case let mesh as ARMeshAnchor:
            self = .mesh(.init(
                center: Transform(matrix: mesh.transform).translation,
                classifications: mesh.geometry.allClassifications()
                    .map(ARUpdates.MeshFacade.Classification.init)))
        case is ARImageAnchor: self = .image
        case is ARFaceAnchor: self = .face
        case is ARBodyAnchor: self = .body
        case is ARObjectAnchor: self = .object
        case is ARGeoAnchor: self = .geo
        default: self = .unknown
        }
    }
}

extension ARUpdates.PlaneFacade.Classification {
    init(_ classification: ARPlaneAnchor.Classification) {
        self = switch classification {
        case .none(let status):
                .none(.init(status))
        case .wall:
                .wall
        case .floor:
                .floor
        case .ceiling:
                .ceiling
        case .table:
                .table
        case .seat:
                .seat
        case .window:
                .window
        case .door:
                .door
        @unknown default:
                .none(.unknown)
        }
    }
}

extension ARUpdates.PlaneFacade.Classification.Status {
    init(_ status: ARPlaneAnchor.Classification.Status) {
        self = switch status {
        case .notAvailable:
                .notAvailable
        case .undetermined:
                .undetermined
        case .unknown:
                .unknown
        @unknown default:
                .unknown
        }
    }
}

extension ARUpdates.MeshFacade.Classification {
    init(_ classification: ARMeshClassification) {
        self = switch classification {
        case .none:
                .none
        case .wall:
                .wall
        case .floor:
                .floor
        case .ceiling:
                .ceiling
        case .table:
                .table
        case .seat:
                .seat
        case .window:
                .window
        case .door:
                .door
        @unknown default:
                .none
        }
    }
}
