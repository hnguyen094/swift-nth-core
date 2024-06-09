//
//  MeshResource+InvertNormals.swift
//
//
//  Created by hung on 6/8/24.
//  https://stackoverflow.com/a/75465683
//  added replacing existing normals with the inverted ones.
#if os(iOS)
import Foundation
import RealityKit

public extension MeshResource {
    // call this to create a 2-sided mesh that will then be displayed
    func addingInvertedNormals() throws -> MeshResource {
        return try MeshResource.generate(from: contents.addingInvertedNormals())
    }

    // call this on a mesh that is already displayed to make it 2 sided
    func addInvertedNormals() throws {
        try replace(with: contents.addingInvertedNormals())
    }

    func invertNormals() throws {
        try replace(with: contents.invertingNormals())
    }

    static func generateTwoSidedPlane(width: Float, depth: Float, cornerRadius: Float = 0) -> MeshResource {
        let plane = generatePlane(width: width, depth: depth, cornerRadius: cornerRadius)
        let twoSided = try? plane.addingInvertedNormals()
        return twoSided ?? plane
    }
}

public extension MeshResource.Contents {
    func addingInvertedNormals() -> MeshResource.Contents {
        var newContents = self

        newContents.models = .init(models.map { $0.addingInvertedNormals() })

        return newContents
    }

    func invertingNormals() -> MeshResource.Contents {
        var newContents = self
        newContents.models = .init(models.map({ $0.invertingNormals() }))
        return newContents
    }
}

public extension MeshResource.Model {
    func partsWithNormalsInverted() -> [MeshResource.Part] {
        return parts.map { $0.normalsInverted() }.compactMap { $0 }
    }

    func addingParts(additionalParts: [MeshResource.Part]) -> MeshResource.Model {
        let newParts = parts.map { $0 } + additionalParts

        var newModel = self
        newModel.parts = .init(newParts)

        return newModel
    }

    func invertingNormals() -> MeshResource.Model {
        var newModel = self
        newModel.parts = .init(partsWithNormalsInverted())
        return newModel
    }

    func addingInvertedNormals() -> MeshResource.Model {
        return addingParts(additionalParts: partsWithNormalsInverted())
    }
}

public extension MeshResource.Part {
    func normalsInverted() -> MeshResource.Part? {
        if let normals, let triangleIndices {
            let newNormals = normals.map { $0 * -1.0 }
            var newPart = self
            newPart.normals = .init(newNormals)
            // ordering of points in the triangles must be reversed,
            // or the inversion of the normal has no effect
            newPart.triangleIndices = .init(triangleIndices.reversed())
            // id must be unique, or others with that id will be discarded
            newPart.id = id + "_inverted"
            return newPart
        } else {
            return .none
        }
    }
}

#endif
