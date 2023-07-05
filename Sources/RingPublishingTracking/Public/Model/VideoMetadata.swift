//
//  VideoMetadata.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Video metadata
public struct VideoMetadata {

    /// Publication identifier in source system (CMS)
    public let publicationId: String


    // MARK: Init

    public init(publicationId: String) {
        self.publicationId = publicationId
    }
}
