//
//  DateExtensions.swift
//  keepers
//
//  Created by Hung on 9/11/23.
//

import Foundation

extension Date {
    /// A description of the calendar elapsed time. This is intended for describing age.
    ///
    /// Compatible range of time units: year -- minute.
    ///
    /// Example -- "5 years" or "1 minute".
    var elapsedTimeDescription: String {
        let pluralS: (Int) -> String = { $0 > 1 ? "s" : "" }
        func helper(_ v: Int,_ unit: String, usePlural: Bool = true) -> String {
            return "\(v) \(unit)\(pluralS(v))"
        }

        let deltas = Calendar.current.dateComponents(
            [.minute, .hour, .day, .weekOfMonth, .month, .year],
            from: self,
            to: Date.now)
        if (deltas.year! > 0) {
            return helper(deltas.year!, "year")
        }
        if (deltas.month! > 0) {
            return helper(deltas.month!, "month")
        }
        if (deltas.weekOfMonth! > 0) {
            return helper(deltas.weekOfMonth!, "week")
        }
        if (deltas.day! > 0) {
            return helper(deltas.day!, "day")
        }
        if (deltas.hour! > 0) {
            return helper(deltas.hour!, "hour")
        }
        if (deltas.minute! > 0) {
            return helper(deltas.minute!, "minute")
        }
        return "< a minute"
    }
}
