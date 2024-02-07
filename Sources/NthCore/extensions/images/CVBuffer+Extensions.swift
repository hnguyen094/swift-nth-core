//
//  CVBuffer+Extensions.swift
//  keepers-tech-demo
//
//  Created by hung.
//

import Vision

// This suppresses the warnning that CVBuffer is being sent across actor-boundary because it isn't @Sendable
// This should be valid because we are not expected CVBuffer to change, unless ARFrame itself is reusing the buffer.
extension CVBuffer: @unchecked Sendable { }
