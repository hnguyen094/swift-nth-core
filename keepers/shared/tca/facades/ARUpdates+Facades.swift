//
//  ARUpdates+Facades.swift
//  keepers
//
//  Created by hung on 1/12/24.
//

import AVFoundation
import UIKit
import simd

extension ARUpdates {
    enum AnchorFacade {
        case plane(PlaneFacade)
        case mesh
        case image
        case face
        case body
        case object
        case geo
        case hand
        case world
        case device
        case unknown
    }

    struct PlaneFacade {
        let center: simd_float3
        let classification: Classification
        
        enum Classification {
            case none(Status)
            case wall
            case floor
            case ceiling
            case table
            case seat
            case window
            case door
            
            enum Status {
                case notAvailable
                case undetermined
                case unknown
            }
        }
    }
        
    struct FrameFacade {
        var capturedImage: CVPixelBuffer
        var capturedDepthData: AVDepthData?
        
        var orientation: UIDeviceOrientation        
        var displayTransform: CGAffineTransform?
    }
}
