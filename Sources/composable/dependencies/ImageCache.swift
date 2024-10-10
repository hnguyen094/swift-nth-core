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
public struct ImageCache: Sendable {
    public var getURL: @Sendable (UIImage) async throws -> URL?
    public var getImage: @Sendable (URL) async throws -> UIImage?
}

extension ImageCache: DependencyKey {
    public static var liveValue: Self {
        let client: Client = .init()
        return .init(
            getURL: { try await client.getURL($0) },
            getImage: { try await client.getImage($0) }
        )
    }

    private actor Client {
        var mapping: [URL: UIImage] = [:]
        func getURL(_ image: UIImage) throws -> URL? {
            if let exist = mapping.first(where: { $0.value == image }) {
                return exist.key
            }
            if let url = try image.saveToTemporaryFile() {
                mapping[url] = image
                return url
            }
            return .none
        }

        func getImage(_ url: URL) throws -> UIImage? {
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
