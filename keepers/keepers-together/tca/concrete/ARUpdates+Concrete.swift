//
//  ARUpdates+Concrete.swift
//  keepers-together
//
//  Created by hung on 1/12/24.
//

import ARKit
import RealityKit
import simd

extension ARUpdates.AnchorFacade {
    init(_ anchor : any Anchor) {
        switch anchor {
        case let plane as PlaneAnchor:
            // TODO: add plane.planeExtent's details and plane.center
            self = .plane(.init(
                center: Transform(matrix: plane.originFromAnchorTransform).translation,
                classification: .init(plane.classification)
            ))
        case let mesh as MeshAnchor:
            self = .mesh(.init(
                center: Transform(matrix: mesh.originFromAnchorTransform).translation,
                classifications: mesh.geometry.allClassifications()
                    .map(ARUpdates.MeshFacade.Classification.init)))
        case is ImageAnchor: self = .image
        case is HandAnchor: self = .hand
        case is WorldAnchor: self = .world
        case is DeviceAnchor: self = .device
        default: self = .unknown
        }
    }
}

extension ARUpdates.PlaneFacade.Classification {
    init(_ classification: PlaneAnchor.Classification) {
        self = switch classification {
        case .notAvailable:
                .none(.notAvailable)
        case .undetermined:
                .none(.undetermined)
        case .unknown:
                .none(.unknown)
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

extension ARUpdates.MeshFacade.Classification {
    init(_ classification: MeshAnchor.MeshClassification) {
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
        case .stairs:
                .stairs
        case .bed:
                .bed
        case .cabinet:
                .cabinet
        case .homeAppliance:
                .homeAppliance
        case .tv:
                .tv
        case .plant:
                .plant
        @unknown default:
                .none
        }
    }
}
