//
//  UIScreenExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 9/12/24.
//

#if os(iOS)
import UIKit

public extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
#endif
