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

struct ContentMarkAsPaid: Encodable {
    let object: ContentObject?
    let publication: Publication
    let source: Source

    enum CodingKeys: String, CodingKey {
        case object
        case publication
        case source
    }

    init?(contentMetadata: ContentMetadata?, objectIdentifier: String?) {
        guard let contentMetadata = contentMetadata else {
            return nil
        }

        if let objectIdentifier = objectIdentifier, !objectIdentifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            object = ContentObject(id: objectIdentifier)
        } else {
            object = nil
        }

        publication = Publication(premium: contentMetadata.paidContent)
        source = Source(id: contentMetadata.contentSpaceUuid, system: contentMetadata.sourceSystemName)
    }
}
