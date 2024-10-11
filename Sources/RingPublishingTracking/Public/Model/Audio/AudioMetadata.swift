//
//  AudioMetadata.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 08/10/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Audio metadata for event tracking
public struct AudioMetadata: Encodable {

    /// Content identifier in source system (CMS)
    public let contentId: String

    /// Content title in source system
    public let contentTitle: String

    /// Content series identifier
    public let contentSeriesId: String?

    /// Content series title
    public let contentSeriesTitle: String?

    /// Audio media type (tts / podcast / livestream etc.)
    public let mediaType: String

    /// Audio duration (in seconds)
    public let audioDuration: Int?

    /// Type of audio stream format loaded into player
    public let audioStreamFormat: AudioStreamFormat

    /// Is audio a part of a bigger content piece
    public let isContentFragment: Bool

    /// Audio content category in terms of paid access to it
    public let audioContentCategory: AudioContentCategory

    /// Audio player version name, for example 1.2.0
    public let audioPlayerVersion: String

    public var audioEventParameter: AudioEventParameter {
        AudioEventParameter(id: contentId,
                            seriesId: contentSeriesId,
                            title: contentTitle,
                            seriesTitle: contentSeriesTitle,
                            mediaType: mediaType)
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - contentId: Content identifier in source system (CMS)
    ///   - contentTitle: Title of the audio content
    ///   - contentSeriesId: Series identifier for the content (if applicable)
    ///   - contentSeriesTitle: Series title for the content (if applicable)
    ///   - mediaType: Type of media (e.g., podcast, brand, radio, etc.)
    ///   - audioDuration: Audio duration (in seconds, optional)
    ///   - audioStreamFormat: Type of audio stream format loaded into audio player
    ///   - isContentFragment: Is this content a fragment or a full piece?
    ///   - audioContentCategory: Audio content category in terms of paid access to it
    ///   - audioPlayerVersion: Audio player version name, for example 1.2.0
    public init(contentId: String,
                contentTitle: String,
                contentSeriesId: String?,
                contentSeriesTitle: String?,
                mediaType: String,
                audioDuration: Int?,
                audioStreamFormat: AudioStreamFormat,
                isContentFragment: Bool,
                audioContentCategory: AudioContentCategory,
                audioPlayerVersion: String) {
        self.contentId = contentId
        self.contentTitle = contentTitle
        self.contentSeriesId = contentSeriesId
        self.contentSeriesTitle = contentSeriesTitle
        self.mediaType = mediaType
        self.audioDuration = audioDuration
        self.audioStreamFormat = audioStreamFormat
        self.isContentFragment = isContentFragment
        self.audioContentCategory = audioContentCategory
        self.audioPlayerVersion = audioPlayerVersion
    }
}
