//
//  UniqueIdentifierDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class UniqueIdentifierDecorator: Decorator {

    private static let pageIdDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"

        return formatter
    }()

    private static let identifierRandomPartLength = 7

    private var primaryIdentifier: String
    private var secondaryIdentifier: String

    init() {
        let initialIdentifier = UniqueIdentifierDecorator.generatePageId()

        primaryIdentifier = initialIdentifier
        secondaryIdentifier = initialIdentifier
    }

    var parameters: [String: AnyHashable] {
        [
            "IP": primaryIdentifier,
            "IV": secondaryIdentifier
        ]
    }

    private static func generatePageId() -> String {
        let now = Date()
        var pageId = Self.pageIdDateFormatter.string(from: now)

        let randomPart = (0..<Self.identifierRandomPartLength).map { _ in String(Int.random(in: 0...9)) }.joined()
        pageId += randomPart

        return pageId
    }
}

extension UniqueIdentifierDecorator {

    func updateIdentifiers() {
        primaryIdentifier = Self.generatePageId()
        secondaryIdentifier = primaryIdentifier
    }

    func updateSecondaryIdentifier() {
        secondaryIdentifier = Self.generatePageId()
    }
}
