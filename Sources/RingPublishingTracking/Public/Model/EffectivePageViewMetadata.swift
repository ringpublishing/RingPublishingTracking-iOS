//
//  EffectivePageViewMetadata.swift
//  Pods
//
//  Created by Bernard Bijoch on 06/06/2025.
//

import Foundation

/// Metadata for effective page view event
struct EffectivePageViewMetadata {
    let componentSource: String
    let triggerSource: String
    let measurement: KeepAliveContentStatus
}
