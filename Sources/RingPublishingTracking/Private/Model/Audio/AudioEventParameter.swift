//
//  AudioEventParameter.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 10/10/2024.
//

import Foundation

/// Audio event parameter
struct AudioEventParameter: Encodable {

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case seriesId = "series_id"
        case title = "title"
        case seriesTitle = "series_title"
        case mediaType = "media_type"
    }

    /// Content id
    let id: String

    /// Content series id
    let seriesId: String?

    /// Content title
    let title: String

    /// Content series title
    let seriesTitle: String?

    /// Media type, like podcast, brand, radio
    let mediaType: AudioMediaType
}
