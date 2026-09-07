//
//  SessionIdentifierDecorator.swift
//  RingPublishingTracking
//
//  Created by Marcin Nowacki on 03/09/2026.
//

import Foundation

final class SessionIdentifierDecorator: Decorator {

    private static let sessionIdDateFormat = "yyyyMMddHHmmss"
    private static let identifierRandomPartLength = 10

    private var sessionIdentifier: String

    init() {
        sessionIdentifier = SessionIdentifierDecorator.generateSessionIdentifier()
    }

    var parameters: [String: AnyHashable] {
        ["IS": sessionIdentifier]
    }

    private static func generateSessionIdentifier() -> String {
        String.timestampIdentifier(
            dateFormat: Self.sessionIdDateFormat,
            randomPartLength: Self.identifierRandomPartLength
        )
    }
}

extension SessionIdentifierDecorator {

    /// Generates a fresh `IS`. Unused for now — required by spec as a hook for a future session-break feature.
    func startNewSession() {
        sessionIdentifier = Self.generateSessionIdentifier()
    }
}
