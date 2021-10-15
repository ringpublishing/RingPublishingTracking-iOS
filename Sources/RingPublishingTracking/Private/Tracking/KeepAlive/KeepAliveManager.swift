//
//  KeepAliveManager.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 13/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

// TODO: MOVE
protocol KeepAliveManagerDelegate: AnyObject {

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata)
}

final class KeepAliveManager {

    weak var delegate: KeepAliveManagerDelegate?

    private weak var contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource?

    private let intervalsProvider = KeepAliveIntervalsProvider()

    func pause() {

    }

    func resume() {

    }

    func stop() {

    }

    func setupContentKeepAliveDataSource(contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource) {
        self.contentKeepAliveDataSource = contentKeepAliveDataSource
    }
}
