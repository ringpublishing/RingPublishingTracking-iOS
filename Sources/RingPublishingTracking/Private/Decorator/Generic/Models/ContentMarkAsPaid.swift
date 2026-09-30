//
//  ContentMarkAsPaid.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 03/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct Publication: Encodable {
    let premium: Bool
}

struct Source: Encodable {
    let id: String
    let system: String

    enum CodingKeys: String, CodingKey {
        case id
        case system
    }
}

struct ContentObject: Encodable {
    let id: String
}

extension ContentObject {

    /// A lowercased UUID, the only `object.id` the data lake accepts. Matched as a pattern rather than with
    /// `UUID(uuidString:)`, so this SDK and the Android one accept exactly the same identifiers.
    private static let identifierPattern = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"

    /// ASCII whitespace only, the set the Android SDK trims as well
    private static let trimmedCharacters = CharacterSet(charactersIn: " \t\n\r\u{0B}\u{0C}")

    /// Creates the content object from the content identifier, trimmed and lowercased
    ///
    /// - Parameters:
    ///   - contentId: Content identifier from `ContentMetadata`
    ///   - invalidContentIdentifiers: Identifiers already logged as not being a UUID
    /// - Returns: `nil` when the identifier is not a UUID
    init?(contentId: String, invalidContentIdentifiers: InvalidContentIdentifiers) {
        let identifier = contentId.trimmingCharacters(in: Self.trimmedCharacters).lowercased()

        // The whole identifier has to match: `$` alone also matches before a trailing line terminator such as U+0085
        guard let match = identifier.range(of: Self.identifierPattern, options: .regularExpression),
              match == identifier.startIndex..<identifier.endIndex else {
            if invalidContentIdentifiers.insert(contentId) {
                Logger.log("Content identifier '\(contentId)' is not a UUID. 'object' is not reported in 'RDLCN'.", level: .default)
            }
            return nil
        }

        self.init(id: identifier)
    }
}

/// Content identifiers already logged as not being a UUID, so each is logged once for the lifetime of the module
/// rather than with every keep alive event of the same content
final class InvalidContentIdentifiers {

    private let lock = NSLock()
    private var identifiers = Set<String>()

    /// Remembers the identifier
    ///
    /// - Parameter identifier: Raw content identifier
    /// - Returns: `True` the first time the identifier is remembered, otherwise `False`
    func insert(_ identifier: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return identifiers.insert(identifier).inserted
    }
}

struct ContentMarkAsPaid: Encodable {
    let object: ContentObject?
    let publication: Publication
    let source: Source

    enum CodingKeys: String, CodingKey {
        case object
        case publication
        case source
    }

    init?(contentMetadata: ContentMetadata?, invalidContentIdentifiers: InvalidContentIdentifiers) {
        guard let contentMetadata = contentMetadata else {
            return nil
        }

        object = ContentObject(contentId: contentMetadata.contentId, invalidContentIdentifiers: invalidContentIdentifiers)
        publication = Publication(premium: contentMetadata.paidContent)
        source = Source(id: contentMetadata.contentSpaceUuid, system: contentMetadata.sourceSystemName)
    }
}
