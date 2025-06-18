//
//  EPVKeepAliveManagerDelegateMock.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 06/06/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol EPVKeepAliveManagerDelegateMockDelegate: AnyObject {
    func didAskForKeepAliveContentStatus() -> KeepAliveContentStatus
}

class EPVKeepAliveManagerDelegateMock: KeepAliveManagerDelegate {

    private(set) var events: [Event] = []
    let eventsFactory = EventsFactory()

    weak var delegate: EPVKeepAliveManagerDelegateMockDelegate?

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource,
                          didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        delegate?.didAskForKeepAliveContentStatus() ?? .zero
    }

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) {
    }

    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          didTakeMeasurement measurement: KeepAliveContentStatus,
                          for contentMetadata: ContentMetadata) {

        guard measurement.shouldSendEffectivePageView else { return }

        let metaData = EffectivePageViewMetadata(componentSource: .other(value: "scroll"),
                                                 triggerSource: .other(value: "scrl"),
                                                 measurement: measurement)

        guard let event = eventsFactory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                               contentMetadata: contentMetadata,
                                                                     metaData: metaData) else {
            return
        }

        events.append(event)
    }
}
