//
//  SequenceDecorator.swift
//  RingPublishingTracking
//
//  Created by Marcin Nowacki on 03/09/2026.
//

import Foundation

final class SequenceDecorator: Decorator {

    private var sequence: Int

    init(sequence: Int = 0) {
        self.sequence = sequence
    }

    var parameters: [String: AnyHashable] {
        ["SQ": sequence]
    }

    func eventDecorated() {
        sequence = nextValue(after: sequence)
    }

    private func nextValue(after value: Int) -> Int {
        value == Int.max ? 0 : value + 1
    }
}
