//
//  UIScreenExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 9/12/24.
//

import UIKit

public extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
