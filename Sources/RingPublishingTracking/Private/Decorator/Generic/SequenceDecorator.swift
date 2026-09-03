//
//  SequenceDecorator.swift
//  RingPublishingTracking
//
//  Created by Marcin Nowacki on 03/09/2026.
//

import Foundation

final class SequenceDecorator: Decorator {

    private var sequence: Int32 = 0

    /// Increments on each access, so every decorated event gets its own `SQ`.
    var parameters: [String: AnyHashable] {
        defer { sequence = Self.nextValue(after: sequence) }

        return ["SQ": sequence]
    }

    static func nextValue(after value: Int32) -> Int32 {
        value == Int32.max ? 0 : value + 1
    }
}
