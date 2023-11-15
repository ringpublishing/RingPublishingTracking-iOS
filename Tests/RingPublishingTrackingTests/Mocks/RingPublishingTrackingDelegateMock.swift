//
//  RingPublishingTrackingDelegateMock.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 28/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import Foundation

class RingPublishingTrackingDelegateMock: RingPublishingTrackingDelegate {

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignTrackingIdentifier identifier: TrackingIdentifier) {

    }

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didFailToRetrieveTrackingIdentifier error: TrackingIdentifierError) {

    }
}
