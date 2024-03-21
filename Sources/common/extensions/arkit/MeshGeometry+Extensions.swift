//
//  MeshGeometry+Extensions.swift
//  keepers
//
//  Created by Hung on 11/23/23.
//

import ARKit

#if os(iOS)
public typealias MeshClassification = ARMeshClassification
typealias MeshGeometry = ARMeshGeometry
extension MeshGeometry {
    var classificationSource: ARGeometrySource? { classification }
}
#elseif os(visionOS)
public typealias MeshClassification = MeshAnchor.MeshClassification
typealias MeshGeometry = MeshAnchor.Geometry
extension MeshGeometry {
    var classificationSource: GeometrySource? { classifications }
}
#endif

public extension MeshGeometry {
    func mainClassification() -> MeshClassification {
        var counts = [MeshClassification:Int]()
        for i in 0..<faces.count {
            counts[classificationOf(faceWithIndex: i), default: 0] += 1
        }
        return counts.sorted(by: { $0.value > $1.value } ).first?.key ?? .none
    }

    func allClassifications() -> [MeshClassification] {
        var result: [MeshClassification] = []
        guard let classifications = classificationSource else { return result }
        var address = classifications.buffer.contents()
        for i in 0..<faces.count {
            address = address.advanced(by: i)
            let value = Int(address.assumingMemoryBound(to: UInt8.self).pointee)
            result.append(.init(rawValue: value) ?? .none)
        }
        return result
    }
    
    func classificationOf(faceWithIndex index: Int) -> MeshClassification {
        guard let classifications = classificationSource else { return .none }
        let classificationAddress = classifications.buffer.contents().advanced(by: index)
        let classificationValue = Int(classificationAddress.assumingMemoryBound(to: UInt8.self).pointee)
        return .init(rawValue: classificationValue) ?? .none
    }
}
