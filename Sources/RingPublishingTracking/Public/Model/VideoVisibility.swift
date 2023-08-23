//
//  VideoVisibility.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 23/08/2023.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Video visibility
public enum VideoVisibility {

    /// Video is visible for the user
    case visible

    /// Video is not visible (out of viewport) for the user
    case outOfViewport
}
