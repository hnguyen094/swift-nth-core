//
//  TimeInverval+Extensions.swift
//  keepers
//
//  Created by Hung on 9/11/23.
//

import Foundation

public extension TimeInterval {
    /// Extension for converting time intervals.
    /// - Author: [Ben Park](https://gist.github.com/ppth0608/edaf9d4e2b1932a72f98688a346805f5 ).
    var weeks: Int {
        return Int((self / 604_800).rounded(.towardZero))
    }
    
    /// Extension for converting time intervals.
    /// - Author: [Ben Park](https://gist.github.com/ppth0608/edaf9d4e2b1932a72f98688a346805f5 ).
    var days: Int {
        return Int((self / 86_400).rounded(.towardZero))
    }
    
    /// Extension for converting time intervals.
    /// - Author: [Ben Park](https://gist.github.com/ppth0608/edaf9d4e2b1932a72f98688a346805f5 ).
    var hours: Int {
        return Int((self / 3_600).rounded(.towardZero))
    }
    
    /// Extension for converting time intervals.
    /// - Author: [Ben Park](https://gist.github.com/ppth0608/edaf9d4e2b1932a72f98688a346805f5 ).
    var minutes: Int {
        return Int((self / 60).rounded(.towardZero))
    }
    
    /// Extension for converting time intervals.
    /// - Author: [Ben Park](https://gist.github.com/ppth0608/edaf9d4e2b1932a72f98688a346805f5 ).
    var seconds: Int {
        return Int(self.rounded(.towardZero))
    }
    
    /// Extension for converting time intervals.
    /// - Author: [Ben Park](https://gist.github.com/ppth0608/edaf9d4e2b1932a72f98688a346805f5 ).
    var milliseconds: Int {
        return Int(self * 1_000)
    }
}
