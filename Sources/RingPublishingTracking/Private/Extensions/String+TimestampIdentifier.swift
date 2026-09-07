//
//  String+TimestampIdentifier.swift
//  RingPublishingTracking
//
//  Created by Marcin Nowacki on 03/09/2026.
//

import Foundation

extension String {

    /// Generates an identifier made of a date formatted using `dateFormatter`, followed by `randomPartLength` random digits
    static func timestampIdentifier(
        dateFormatter: DateFormatter,
        randomPartLength: Int,
        date: Date = Date()
    ) -> String {
        let randomPart = (0..<randomPartLength)
            .map { _ in String(Int.random(in: 0...9)) }
            .joined()

        return dateFormatter.string(from: date) + randomPart
    }
}
