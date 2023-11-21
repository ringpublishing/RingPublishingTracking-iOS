//
//  RingPublishingTracking+EventsServiceDelegate.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 05/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Events Service Delegate
extension RingPublishingTracking: EventsServiceDelegate {

    func eventsService(_ eventsService: EventsService, retrievedTrackingIdentifier identifier: TrackingIdentifier) {
        delegate?.ringPublishingTracking(self, didAssignTrackingIdentifier: identifier)
    }

    func eventsService(_ eventsService: EventsService, didFailWhileRetrievingTrackingIdentifier error: ServiceError) {
        let trackingError = TrackingIdentifierError(serviceError: error)
        delegate?.ringPublishingTracking(self, didFailToRetrieveTrackingIdentifier: trackingError)
    }
}
