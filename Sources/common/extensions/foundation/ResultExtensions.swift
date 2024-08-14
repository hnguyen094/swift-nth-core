//
//  ResultExtensions.swift
//  swift-nth-core
//
//  Created by hung on 8/14/24.
//
//  https://stackoverflow.com/a/72560883

public extension Result where Success == Void {
    /// A success, storing a Success value.
    ///
    /// Instead of `.success(())`, now  `.success`
    static var success: Result {
        return .success(())
    }
}
