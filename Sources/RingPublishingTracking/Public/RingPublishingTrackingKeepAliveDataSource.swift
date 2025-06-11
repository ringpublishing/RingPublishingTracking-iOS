//
//  RingPublishingTrackingKeepAliveDataSource.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import CoreGraphics

/// Keep alive content status
public struct KeepAliveContentStatus {
    let scrollOffset: CGFloat
    let contentSize: CGSize
    let screenSize: CGSize

    static var zero: KeepAliveContentStatus {
        return KeepAliveContentStatus(scrollOffset: 0, contentSize: .zero, screenSize: .zero)
    }

    private static let sizeProvider = SizeProvider()

    public init(scrollOffset: CGFloat, contentSize: CGSize, screenSize: CGSize = Self.sizeProvider.screenSize) {
        self.scrollOffset = scrollOffset
        self.contentSize = contentSize
        self.screenSize = screenSize
    }

    public var shouldSendEffectivePageView: Bool {
        scrollOffset >= 2 * screenSize.height
    }
}

/// RingPublishingTracking keep alive data source
public protocol RingPublishingTrackingKeepAliveDataSource: AnyObject {

    /// Data source method asking for updated status for tracked content
    ///
    /// - Returns: KeepAliveContentStatus
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus
}
