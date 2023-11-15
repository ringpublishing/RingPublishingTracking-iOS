//
//  KeepAliveDataSourceStub.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 19/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

class KeepAliveDataSourceStub: RingPublishingTrackingKeepAliveDataSource {
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        (scrollOffset: 0, contentSize: .init(width: 375, height: 1200))
    }
}
