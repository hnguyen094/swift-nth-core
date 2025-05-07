//
//  BundleExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 4/7/25.
//

import Foundation

public extension Bundle {
    static var appVersion: String? {
        #if os(macOS)
        let key = "CFBundleShortVersionString"
        #else
        let key = "CFBundleVersion"
        #endif
        return Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    static var displayName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
