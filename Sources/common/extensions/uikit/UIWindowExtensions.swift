//
//  UIWindowExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 9/12/24.
//

#if os(iOS)
import UIKit

public extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}
#endif
