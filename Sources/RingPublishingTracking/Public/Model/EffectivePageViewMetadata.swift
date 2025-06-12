//
//  EffectivePageViewMetadata.swift
//  Pods
//
//  Created by Bernard Bijoch on 06/06/2025.
//

import Foundation

/// ES parameter
public enum EffectivePageViewComponentSource: String {
    case scroll
    case audio
    case video
    case onetchat
}

/// RS parameter
public enum EffectivePageViewTriggerSource: String {
    case scrl
    case play
    case summary
}

/// Metadata for effective page view event
struct EffectivePageViewMetadata {
    let componentSource: EffectivePageViewComponentSource
    let triggerSource: EffectivePageViewTriggerSource
    let measurement: KeepAliveContentStatus
}
