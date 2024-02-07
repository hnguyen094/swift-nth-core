//
//  VPTree.swift
//  keepers
//
//  Created by Hung.
//
//  based on: https://github.com/huyng/algorithms/blob/master/vptree/vptree.py

import Foundation
import simd

import DequeModule
import SwiftPriorityQueue

public class VPTree<Object: Equatable> {
    public typealias DistanceFunction = (SIMD3<Float>, SIMD3<Float>) -> Float
    
    public struct Point: Equatable {
        public let position: simd_float3
        public let object: Object
    }

    public struct Neighbor: Comparable {
        public let distance: Float
        public let point: Point
        
        public static func <(lhs: Self, rhs: Self) -> Bool {
            lhs.distance < rhs.distance
        }
    }

    private var left: VPTree<Object>? = .none
    private var right: VPTree<Object>? = .none

    let distanceFunction: DistanceFunction
    private let vantagePoint: Point
    private let radius: Float

    public init?(points: [Point], distanceFunction: DistanceFunction? = .none) {
        guard let randomElement = points.randomElement() else {
            return nil
        }
        vantagePoint = randomElement
        self.distanceFunction = distanceFunction ?? Self.l2
        let distanceFn = self.distanceFunction
        let distances = points.map({ distanceFn(randomElement.position, $0.position) })
        radius = Self.median(distances)!
        var leftPoints: [Point] = []
        var rightPoints: [Point] = []
    
        for (point, distance) in zip(points, distances) {
            if point == vantagePoint { continue }
            if distance >= radius {
                rightPoints.append(point)
            } else {
                leftPoints.append(point)
            }
        }
        if !leftPoints.isEmpty {
            left = VPTree(points: leftPoints, distanceFunction: self.distanceFunction)
        }
        if !rightPoints.isEmpty {
            left = VPTree(points: rightPoints, distanceFunction: self.distanceFunction)
        }
    }

    public func isLeaf() -> Bool {
        if case .none = left, case .none = right { true }
        else { false }
    }

    public func getNearestNeighbors(of point: simd_float3, n: Int = 1) -> any Sequence<Neighbor> {
        var neighbors = PriorityQueue<Neighbor>()
        var toVisit = Deque<VPTree<Object>?>()
        var furthestDistance: Float = .infinity
        
        toVisit.append(self)
        while !toVisit.isEmpty {
            guard let first = toVisit.popFirst(), let node = first else { continue }
            let distance = distanceFunction(point, node.vantagePoint.position)
            if distance < furthestDistance {
                neighbors.push(.init(distance: distance, point: node.vantagePoint))
                furthestDistance = neighbors.min()!.distance
            }
            if node.isLeaf() { continue }
            
            if distance < node.radius {
                if distance < node.radius + furthestDistance {
                    toVisit.append(node.left)
                }
                if distance >= node.radius - furthestDistance {
                    toVisit.append(node.right)
                }
            } else {
                if distance >= node.radius - furthestDistance {
                    toVisit.append(node.right)
                }
                if distance < node.radius + furthestDistance {
                    toVisit.append(node.left)
                }
            }
        }
        return neighbors
    }

    public func getInRange(of point: simd_float3, range: Float) -> any Sequence<Neighbor> {
        var toVisit = Deque<VPTree<Object>?>()
        toVisit.append(self)
        var neighbors: [Neighbor] = []
        
        while !toVisit.isEmpty {
            guard let first = toVisit.popFirst(), let node = first else { continue }
            let distance = distanceFunction(point, node.vantagePoint.position)
            if distance < range {
                neighbors.append(.init(distance: distance, point: node.vantagePoint))
            }
            if node.isLeaf() { continue }
            if distance < node.radius {
                if distance < node.radius + range {
                    toVisit.append(node.left)
                }
                if distance >= node.radius - range {
                    toVisit.append(node.right)
                }
            } else {
                if distance >= node.radius - range {
                    toVisit.append(node.right)
                }
                if distance < node.radius + range {
                    toVisit.append(node.left)
                }
            }
        }
        
        return neighbors
    }

    public static func median(_ elements: [Float]) -> Float? {
        let count = elements.count
        guard count != 0 else {
            return .none
        }
        let sorted = elements.sorted()
        if Double(count).truncatingRemainder(dividingBy: 2) == 0 {
            let right = count / 2
            let left = right - 1
            return (sorted[left] + sorted[right]) / 2
        }
        return sorted[count / 2]
    }
    
    public static func l2(p1: SIMD3<Float>, p2:  SIMD3<Float>) -> Float {
        let sum = pow(p2.x-p1.x, 2) + pow(p2.y-p1.y, 2) + pow(p2.z-p1.z, 2)
        return sqrt(sum)
    }
    
    public static func squaredDistance(p1: SIMD3<Float>, p2: SIMD3<Float>) -> Float {
        return simd_fast_distance(p1, p2)
    }
}
