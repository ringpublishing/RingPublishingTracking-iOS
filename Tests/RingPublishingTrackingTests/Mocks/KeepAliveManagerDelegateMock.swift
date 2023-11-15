//
//  KeepAliveManagerDelegateMock.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 19/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import Foundation

class KeepAliveManagerDelegateMock: KeepAliveManagerDelegate {
    private(set) var keepAliveMetaData: [KeepAliveMetadata] = []

    var measurementTypes: [KeepAliveMeasureType] {
        keepAliveMetaData.flatMap { $0.keepAliveMeasureType }
    }

    var measurementsCount: Int {
        keepAliveMetaData.reduce(0) { partialResult, metaData in
            metaData.keepAliveMeasureType.count + partialResult
        }
    }

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource,
                          didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        (scrollOffset: 0, contentSize: .init(width: 375, height: 1200))
    }

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) {
        keepAliveMetaData.append(metaData)
    }
}
