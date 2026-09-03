//
//  SessionIdentifierDecorator.swift
//  RingPublishingTracking
//
//  Created by Marcin Nowacki on 03/09/2026.
//

import Foundation

final class SessionIdentifierDecorator: Decorator {

    private static let sessionIdDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        return formatter
    }()

    private static let identifierRandomPartLength = 10

    private var sessionIdentifier: String

    init() {
        sessionIdentifier = SessionIdentifierDecorator.generateSessionIdentifier()
    }

    var parameters: [String: AnyHashable] {
        ["IS": sessionIdentifier]
    }

    private static func generateSessionIdentifier() -> String {
        let now = Date()
        var sessionId = Self.sessionIdDateFormatter.string(from: now)

        let randomPart = (0..<Self.identifierRandomPartLength).map { _ in String(Int.random(in: 0...9)) }.joined()
        sessionId += randomPart

        return sessionId
    }
}

extension SessionIdentifierDecorator {

    /// Generates a fresh `IS`. Unused for now — required by spec as a hook for a future session-break feature.
    func startNewSession() {
        sessionIdentifier = Self.generateSessionIdentifier()
    }
}
