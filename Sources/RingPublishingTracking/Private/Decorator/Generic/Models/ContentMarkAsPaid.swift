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

struct ContentMarkAsPaid: Encodable {
    let publication: Publication
    let source: Source

    enum CodingKeys: String, CodingKey {
        case publication
        case source
    }

    init?(contentMetadata: ContentMetadata?) {
        guard let contentMetadata = contentMetadata else {
            return nil
        }

        publication = Publication(premium: contentMetadata.paidContent)
        source = Source(id: contentMetadata.contentSpaceUuid ?? "123", system: contentMetadata.sourceSystemName)
    }
}
