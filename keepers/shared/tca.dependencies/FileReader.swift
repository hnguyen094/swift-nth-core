//
//  File.swift
//  keepers
//
//  Created by Hung on 11/23/23.
//

import Dependencies
import DependenciesMacros
import Foundation

extension DependencyValues {
    var fileReader: FileReader {
        get { self[FileReader.self] }
        set { self[FileReader.self] = newValue }
    }
}

@DependencyClient
public struct FileReader {
    public var readText: (_ file: String) throws -> String
}

extension FileReader: DependencyKey {
    public static var testValue: Self = .init()
    public static var previewValue: Self = .init()

    public static var liveValue: Self { 
        .init(
            readText: { file in
                guard let path = Bundle.main.path(forResource: file, ofType: .none) else {
                    throw Error.invalidPath
                }
                return try String.init(contentsOfFile: path)
            }
        )
    }

    public enum Error: Swift.Error {
        case invalidPath
    }
}
