//
//  AudioMediaType.swift
//  RingPublishingTracking
//
//  Created by Bartłomiej Łaski on 06/12/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Audio media type is used for analytics
public enum AudioMediaType: String, Encodable {

    /// Represents audio content in the format of podcasts, typically longer thematic recordings designed for regular listening in episodes.
    case podcast

    /// Refers to audio content created or sponsored by brands, often used for marketing, brand awareness, or product promotion purposes.
    case brand

    /// Represents traditional live radio broadcasts or their digital equivalents,
    /// offering a wide range of content such as music, news, or thematic shows.
    case radio

    /// Stands for "Text-to-Speech", referring to synthetically generated audio from text,
    /// often used in accessibility applications, voice assistants, or automation.
    case tts
}
