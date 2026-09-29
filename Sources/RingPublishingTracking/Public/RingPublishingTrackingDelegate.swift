//
//  RingPublishingTrackingDelegate.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// RingPublishingTracking module delegate
public protocol RingPublishingTrackingDelegate: AnyObject {

    /// Delegate method informing when RingPublishingTracking module did set tracking identifier assigned to this device
    ///
    /// - Parameters:
    ///   - ringPublishingTracking: RingPublishingTracking
    ///   - identifier: Assigned tracking identifier
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignTrackingIdentifier identifier: TrackingIdentifier)

    /// Delegate method informing that RingPublishingTracking module failed to assign tracking identifier.
    /// This method will be called every time there was an attempt to fetch tracking identifier but it failed
    /// (during module initialization or when another attempt to fetch tracking identifier was performed)
    ///
    /// - Parameters:
    ///   - ringPublishingTracking: RingPublishingTracking
    ///   - error: TrackingIdentifierError
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didFailToRetrieveTrackingIdentifier error: TrackingIdentifierError)

    /// Delegate method informing that RingPublishingTracking module generated the session identifier ("IS").
    /// Called synchronously during `initialize`, without waiting for the backend identifiers.
    /// The value is the same one later delivered in `TrackingIdentifier.sessionIdentifier`.
    ///
    /// - Parameters:
    ///   - ringPublishingTracking: RingPublishingTracking
    ///   - identifier: Session identifier
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignSessionIdentifier identifier: String)
}

public extension RingPublishingTrackingDelegate {

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignSessionIdentifier identifier: String) {}
}
