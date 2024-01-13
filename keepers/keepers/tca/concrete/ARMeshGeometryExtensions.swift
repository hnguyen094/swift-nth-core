import ARKit

extension ARMeshGeometry {
    func mainClassification() -> ARMeshClassification {
        var counts = [ARMeshClassification:Int]()
        for i in 0..<faces.count {
            counts[classificationOf(faceWithIndex: i), default: 0] += 1
        }
        return counts.sorted(by: { $0.value > $1.value } ).first?.key ?? .none
    }
    
    
    func allClassifications() -> [ARMeshClassification] {
        var result: [ARMeshClassification] = []
        guard let classification = classification else { return result }
        var address = classification.buffer.contents()
        for i in 0..<faces.count {
            address = address.advanced(by: i)
            let value = Int(address.assumingMemoryBound(to: UInt8.self).pointee)
            result.append(.init(rawValue: value) ?? .none)
        }
        return result
    }
    
    func classificationOf(faceWithIndex index: Int) -> ARMeshClassification {
        guard let classification = classification else { return .none }
        let classificationAddress = classification.buffer.contents().advanced(by: index)
        let classificationValue = Int(classificationAddress.assumingMemoryBound(to: UInt8.self).pointee)
        return ARMeshClassification(rawValue: classificationValue) ?? .none
    }
}
