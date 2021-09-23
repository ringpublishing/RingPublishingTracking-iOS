//
//  AppTrackingKeepAliveDataSource.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import CoreGraphics

/// Keep alive content status
public typealias KeepAliveContentStatus = (scrollOffset: CGFloat, contentSize: CGSize)

/// AppTracking keep alive data source
public protocol AppTrackingKeepAliveDataSource: AnyObject {

    /// Data source method asking for updated status for tracked content
    ///
    /// - Returns: KeepAliveContentStatus
    func appTracking(_ appTracking: AppTracking, didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus
}
