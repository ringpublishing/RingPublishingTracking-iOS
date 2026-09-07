//
//  String+TimestampIdentifier.swift
//  RingPublishingTracking
//
//  Created by Marcin Nowacki on 03/09/2026.
//

import Foundation

extension String {

    /// Generates an identifier made of a date formatted using `dateFormat`, followed by `randomPartLength` random digits
    static func timestampIdentifier(
        dateFormat: String,
        randomPartLength: Int,
        date: Date = Date()
    ) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat

        let randomPart = (0..<randomPartLength)
            .map { _ in String(Int.random(in: 0...9)) }
            .joined()

        return formatter.string(from: date) + randomPart
    }
}
