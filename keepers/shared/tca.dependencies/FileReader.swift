//
//  File.swift
//  keepers
//
//  Created by Hung on 11/23/23.
//

import SwiftUI
import Dependencies

extension DependencyValues {
    var fileReader: FileReader {
        get { self[FileReader.self] }
        set { self[FileReader.self] = newValue }
    }
}

struct FileReader {
    var readText: (_ file: String) throws -> LocalizedStringKey
}

extension FileReader: DependencyKey {
    static let liveValue = liveClient
    
    static let liveClient = Self(
        readText: { file in
            let path = Bundle.main.path(forResource: file, ofType: nil)
            if path == nil {
                return "[attributions file not found]"
            }
            return try LocalizedStringKey(String.init(contentsOfFile: path!))
        })
}
