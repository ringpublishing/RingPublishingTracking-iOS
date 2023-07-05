//
//  RingPublishingTracking+Video.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/07/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to Video events
public extension RingPublishingTracking {

    // MARK: Video events

    /// Report Video player event
    ///
    /// - Parameters:
    ///   - videoEvent: Type of Video event to report
    ///   - videoMetadata: Video material metadata
    func reportVideoEvent(_ videoEvent: VideoEvent, videoMetadata: VideoMetadata) {
        Logger.log("Reporting video event: '\(videoEvent)' for publicationId: '\(videoMetadata.publicationId)'")



        
    }

}
