//
//  Event.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Generic event which can be send using RingPublishingTracking module
public struct Event {

    /// Name of the analytic system where event should be stored
    public let analyticsSystemName: String

    /// Name of the reported event
    public let eventName: String

    /// Event parameters
    public let eventParameters: [String: AnyHashable]

    // MARK: Init

    /// Initializer
    ///
    /// - Parameters:
    ///   - analyticsSystemName: Name of the analytic system where event should be stored
    ///   - eventName: Name of the reported event
    ///   - eventParameters: Event parameters
    public init(analyticsSystemName: String, eventName: String, eventParameters: [String: AnyHashable]) {
        self.analyticsSystemName = analyticsSystemName
        self.eventName = eventName
        self.eventParameters = eventParameters
    }

    /// Convenience initializer. `analyticsSystemName` parameters will have default value
    ///
    /// - Parameters:
    ///   - analyticsSystemName: Name of the analytic system where event should be stored
    ///   - eventName: Name of the reported event
    ///   - eventParameters: Event parameters
    public init(eventName: String, eventParameters: [String: AnyHashable]) {
        self.init(analyticsSystemName: Constants.eventDefaultAnalyticsSystemName,
                  eventName: eventName,
                  eventParameters: eventParameters)
    }

    /// Convenience initializer. `analyticsSystemName` and `eventName` parameters will have default values
    ///
    /// - Parameter eventParameters: Event parameters
    public init(eventParameters: [String: AnyHashable]) {
        self.init(analyticsSystemName: Constants.eventDefaultAnalyticsSystemName,
                  eventName: Constants.eventDefaultName,
                  eventParameters: eventParameters)
    }
}
