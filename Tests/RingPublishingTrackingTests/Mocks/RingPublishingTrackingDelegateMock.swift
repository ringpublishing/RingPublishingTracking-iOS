//
//  RingPublishingTrackingDelegateMock.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 28/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

class RingPublishingTrackingDelegateMock: RingPublishingTrackingDelegate {

    private(set) var assignedSessionIdentifiers: [String] = []

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignSessionIdentifier identifier: String) {
        assignedSessionIdentifiers.append(identifier)
    }

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignTrackingIdentifier identifier: TrackingIdentifier) {

    }

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didFailToRetrieveTrackingIdentifier error: TrackingIdentifierError) {

    }
}
