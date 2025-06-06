//
//  RingPublishingTracking+KeepAliveManagerDelegate.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 15/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Keep Alive Manager Delegate
extension RingPublishingTracking: KeepAliveManagerDelegate {

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource,
                          didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        contentKeepAliveDataSource.ringPublishingTracking(self, didAskForKeepAliveContentStatus: content)
    }

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) {
        Logger.log("Sending keep alive event")

        let event = eventsFactory.createKeepAliveEvent(metaData: metaData, contentMetadata: contentMetadata)
        reportEvents([event])
    }

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          didTakeMeasurement measurement: KeepAliveContentStatus,
                          for contentMetadata: ContentMetadata) {

        guard eventsService?.isEffectivePageViewEventSent == false, measurement.shouldSendEffectivePageView else { return }

        eventsService?.isEffectivePageViewEventSent = true

        let metaData = EffectivePageViewMetadata(componentSource: .scroll, triggerSource: .scrl, measurement: measurement)

        let event = eventsFactory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                               contentMetadata: contentMetadata,
                                                               metaData: metaData)
        reportEvent(event)
    }
}
