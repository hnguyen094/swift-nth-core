//
//  UIColor+Extensions.swift
//  keepers
//
//  Created by Hung on 9/21/23.
//

import SwiftUI
import UIKit

public extension UIColor {
    /// A color that reflects the accent color of the system or app.
    ///
    /// The accent color is a broad theme color applied to
    /// views and controls. You can set it at the application level by specifying
    /// an accent color in your app's asset catalog.
    ///
    /// > Note: In macOS, SwiftUI applies customization of the accent color
    /// only if the user chooses Multicolor under General > Accent color
    /// in System Preferences.
    ///
    static let accentColor = UIColor(.accentColor)
    
    
    /// The SwiftUI color that corresponds to the color object.
    var color: Color { .init(self) }
}
