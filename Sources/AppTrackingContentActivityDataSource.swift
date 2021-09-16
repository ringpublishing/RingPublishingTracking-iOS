//
//  AppTrackingContentActivityDataSource.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import CoreGraphics

/// Content activity status
public typealias ContentActivityStatus = (scrollOffset: CGFloat, contentSize: CGSize)

/// AppTracking content activity data source
public protocol AppTrackingContentActivityDataSource: AnyObject {

    /// Data source method asking for updated status for tracked content
    ///
    /// - Returns: ContentActivityStatus
    func appTracking(_ appTracking: AppTracking, didAskForContentStatus content: ContentMetadata) -> ContentActivityStatus
}
