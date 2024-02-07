//
//  UIInterfaceOrientation+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung.
//

import UIKit

public extension UIInterfaceOrientation {
    init(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: self = .portrait
        }
    }
}
