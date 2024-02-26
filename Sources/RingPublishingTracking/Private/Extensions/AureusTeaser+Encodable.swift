//
//  AureusTeaser+Encodable.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 19/02/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension Array where Element == AureusTeaser {

    var asJsonArray: [[String: String]] {
        self.map { teaser in
            return [
                "teaser_id": teaser.teaserId,
                "content_id": teaser.contentId
            ]
        }
    }
}
