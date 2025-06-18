//
//  EffectivePageViewMetadata.swift
//  Pods
//
//  Created by Bernard Bijoch on 06/06/2025.
//

import Foundation

/// ES parameter
public enum EffectivePageViewComponentSource {
    case audio
    case video
    case other(value: String)

    var value: String {
        switch self {
        case .audio:
            return "audio"
        case .video:
            return "video"
        case .other(let value):
            return value
        }
    }
}

/// RS parameter
public enum EffectivePageViewTriggerSource {
    case play
    case other(value: String)

    var value: String {
        switch self {
        case .play:
            return "play"
        case .other(let value):
            return value
        }
    }
}

/// Metadata for effective page view event
struct EffectivePageViewMetadata {
    let componentSource: EffectivePageViewComponentSource
    let triggerSource: EffectivePageViewTriggerSource
    let measurement: KeepAliveContentStatus
}
