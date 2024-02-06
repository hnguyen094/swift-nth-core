//
//  dimensionsApp.swift
//  dimensions
//
//  Created by hung on 2/6/24.
//

import SwiftUI

@main
struct dimensionsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
