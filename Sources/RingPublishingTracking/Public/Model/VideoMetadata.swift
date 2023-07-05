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

    /// Content identifier in source system (CMS)
    public let contentId: String

    /// Type of video stream format loaded into video player
    public let videoStreamFormat: VideoStreamFormat

    /// Video duration (in seconds)
    public let videoDuration: Int

    // MARK: Init

    /// Initializer
    /// 
    /// - Parameters:
    ///   - publicationId: Publication identifier in source system (CMS)
    ///   - contentId: Content identifier in source system (CMS)
    ///   - videoStreamFormat: Type of video stream format loaded into video player
    ///   - videoDuration: Video duration (in seconds)
    public init(publicationId: String, contentId: String, videoStreamFormat: VideoStreamFormat, videoDuration: Int) {
        self.publicationId = publicationId
        self.contentId = contentId
        self.videoStreamFormat = videoStreamFormat
        self.videoDuration = videoDuration
    }
}
