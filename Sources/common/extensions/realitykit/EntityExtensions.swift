//
//  EntityExtensions.swift
//  keepers
//
//  Created by hung on 6/11/24.
//

import RealityKit

public extension Entity {
    func changeMaterial(_ materials: [Material]) {
        children.forEach { $0.changeMaterial(materials) }

        guard var comp = components[ModelComponent.self] else { return }
        comp.materials = materials
        components[ModelComponent.self] = comp

    }
}
