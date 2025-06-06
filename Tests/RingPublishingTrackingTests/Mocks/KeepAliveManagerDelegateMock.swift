//
//  KeepAliveManagerDelegateMock.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 19/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

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
        KeepAliveContentStatus(scrollOffset: 0,
                               contentSize: .init(width: 375, height: 1200),
                               screenSize: CGSize(width: 375, height: 800))
    }

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) {
        keepAliveMetaData.append(metaData)
    }

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          didTakeMeasurement measurement: KeepAliveContentStatus,
                          for contentMetadata: ContentMetadata) {
    }
}
