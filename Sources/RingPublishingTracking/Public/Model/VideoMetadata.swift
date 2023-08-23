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

    /// Is video a main content piece?
    /// True if video player is a key part of the content; false otherwise
    public let isMainContentPiece: Bool

    /// Type of video stream format loaded into video player
    public let videoStreamFormat: VideoStreamFormat

    /// Video duration (in seconds)
    public let videoDuration: Int

    /// Video content category in terms of paid access to it
    public let videoContentCategory: VideoContentCategory

    /// Video ads configuration
    public let videoAdsConfiguration: VideoAdsConfiguration

    /// Video player version name, for example 2.9.0
    public let videoPlayerVersion: String

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - publicationId: Publication identifier in source system (CMS)
    ///   - contentId: Content identifier in source system (CMS)
    ///   - isMainContentPiece: Is video a main content piece?
    ///   - videoStreamFormat: Type of video stream format loaded into video player
    ///   - videoDuration: Video duration (in seconds)
    ///   - videoContentCategory: Video content category in terms of paid access to it
    ///   - videoAdsConfiguration: Video ads configuration
    ///   - videoPlayerVersion: Video player version name, for example 2.9.0
    public init(publicationId: String,
                contentId: String,
                isMainContentPiece: Bool,
                videoStreamFormat: VideoStreamFormat,
                videoDuration: Int,
                videoContentCategory: VideoContentCategory,
                videoAdsConfiguration: VideoAdsConfiguration,
                videoPlayerVersion: String) {
        self.publicationId = publicationId
        self.contentId = contentId
        self.isMainContentPiece = isMainContentPiece
        self.videoStreamFormat = videoStreamFormat
        self.videoDuration = videoDuration
        self.videoContentCategory = videoContentCategory
        self.videoAdsConfiguration = videoAdsConfiguration
        self.videoPlayerVersion = videoPlayerVersion
    }
}
