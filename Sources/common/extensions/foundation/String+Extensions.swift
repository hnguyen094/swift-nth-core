//
//  String+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung on 1/23/24.
//

import Foundation

public extension String {
    static let zwsp: Self = "​"

    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
