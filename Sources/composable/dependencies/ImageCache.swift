//
//  ImageCache.swift
//
//
//  Created by hung on 3/12/24.
//

import Dependencies
import DependenciesMacros

import Foundation
import UIKit

extension DependencyValues {
    public var imageCache: ImageCache {
        get { self[ImageCache.self] }
        set { self[ImageCache.self] = newValue }
    }
}

@DependencyClient
public struct ImageCache {
    public var getURL: (UIImage) throws -> URL?
    public var getImage: (URL) throws -> UIImage?
}

extension ImageCache: DependencyKey {
    public static let testValue: Self = .init()
    public static let previewValue: Self = .init()
    public static var liveValue: Self {
        var mapping: [URL: UIImage] = [:]
        return .init { image in
            if let exist = mapping.first(where: { $0.value == image }) {
                return exist.key
            }
            if let url = try image.saveToTemporaryFile() {
                mapping[url] = image
                return url
            }
            return .none
        } getImage: { url in
            if let index = mapping.index(forKey: url) {
                return mapping[index].value
            }
            if let image = UIImage(data: try Data(contentsOf: url)) {
                mapping[url] = image
                return image
            }
            return .none
        }
    }
}

extension UIImage {
    func saveToTemporaryFile() throws -> URL? {
        let imageData = self.jpegData(compressionQuality: 90)
        let filename = "\(ProcessInfo.processInfo.globallyUniqueString).jpg"
        let url = URL.init(filePath: NSTemporaryDirectory()).appending(path: filename)
        try imageData?.write(to: url, options: .atomic)
        return url
    }
}
