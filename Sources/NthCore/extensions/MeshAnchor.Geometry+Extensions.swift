//
//  MeshAnchor.Geometry+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/21/24.
//

import ARKit

extension MeshAnchor.Geometry {
    public func mainClassification() -> MeshAnchor.MeshClassification {
        var counts = [MeshAnchor.MeshClassification:Int]()
        for i in 0..<faces.count {
            counts[classificationOf(faceWithIndex: i), default: 0] += 1
        }
        return counts.sorted(by: { $0.value > $1.value } ).first?.key ?? .none
    }
    
    public func allClassifications() -> [MeshAnchor.MeshClassification] {
        var result: [MeshAnchor.MeshClassification] = []
        guard let classifications = classifications else { return result }
        var address = classifications.buffer.contents()
        for i in 0..<faces.count {
            address = address.advanced(by: i)
            let value = Int(address.assumingMemoryBound(to: UInt8.self).pointee)
            result.append(.init(rawValue: value) ?? .none)
        }
        return result
    }
    
    public func classificationOf(faceWithIndex index: Int) -> MeshAnchor.MeshClassification {
        guard let classifications = classifications else { return .none }
        let classificationAddress = classifications.buffer.contents().advanced(by: index)
        let classificationValue = Int(classificationAddress.assumingMemoryBound(to: UInt8.self).pointee)
        return MeshAnchor.MeshClassification(rawValue: classificationValue) ?? .none
    }
}
