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

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) {
        let event = eventsFactory.createKeepAliveEvent(metaData: metaData, contentMetadata: contentMetadata)
        reportEvents([event])
    }
}
