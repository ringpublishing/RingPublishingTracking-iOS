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

extension DateFormatter {

    /// Formatter for the date part of a timestamp identifier. The backend accepts only ASCII digits, so the output must not
    /// follow the device's calendar, numbering system or 12-hour time setting (which rewrites `HH` to `h a`).
    static func timestampIdentifierFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = dateFormat

        return formatter
    }
}
