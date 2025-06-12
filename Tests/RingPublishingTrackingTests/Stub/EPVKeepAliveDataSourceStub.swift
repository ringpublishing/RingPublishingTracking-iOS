//
//  EPVKeepAliveDataSourceStub.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 06/06/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

class EPVKeepAliveDataSourceStub: EPVKeepAliveManagerDelegateMockDelegate, RingPublishingTrackingKeepAliveDataSource {

    private static let screenSize = UIScreen.main.bounds.size
    private static let contentSize = CGSize(width: screenSize.width, height: 2000)
    private var scrollOffset: CGFloat = 0

    func scrollContentToTop() {
        scrollOffset = 0
    }

    func scrollContentOneScreenDown() {
        scrollOffset = Self.screenSize.height
    }

    func scrollContentTwoScreensDown() {
        scrollOffset = Self.screenSize.height * 2
    }

    func didAskForKeepAliveContentStatus() -> KeepAliveContentStatus {
        return KeepAliveContentStatus(scrollOffset: scrollOffset, contentSize: Self.contentSize)
    }

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        return KeepAliveContentStatus(scrollOffset: scrollOffset, contentSize: Self.contentSize)
    }
}
