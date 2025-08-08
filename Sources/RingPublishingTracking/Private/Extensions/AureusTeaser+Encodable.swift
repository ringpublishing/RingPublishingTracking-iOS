//
//  AureusTeaser+Encodable.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 08/08/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension Array where Element == AureusTeaser {

    var asJsonArray: [[String: String?]] {
        self.map { teaser in
            return [
                "teaser_id": teaser.teaserId,
                "content_id": teaser.contentId
            ]
        }
    }
}
