//
//  CollectionExtensions.swift
//  swift-nth-core
//
//  Created by Hung Nguyen on 2/21/25.
//

import Foundation

public extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.

    /**
     Returns the element at the specified index if it is within bounds, otherwise nil.
     - Author:  [Nikita Kukushkin](https://stackoverflow.com/a/30593673)
     */
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /**
     Returns the distance from the start index.
     - Author: [Leo Dabus](https://stackoverflow.com/a/34540310)
     */
    func distance(to index: Index) -> Int { distance(from: startIndex, to: index) }
}
