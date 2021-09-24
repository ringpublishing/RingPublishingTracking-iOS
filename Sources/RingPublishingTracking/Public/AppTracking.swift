//
//  RingPublishingTracking.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Main class for RingPublishingTracking module
public class RingPublishingTracking {

    // MARK: Public properties

    /// Shared instance
    public static let shared = RingPublishingTracking()

    /// Tracking identifier assigned by the module for this device
    public private(set) var trackingIdentifier: String?

    /// Closure which can be used to gather module logs inside host application
    ///
    /// Module is using os_log to report what is happening - but if this is not enough you can get all logged messages using this closure
    /// For os_log there is defined:
    /// - subsystem: Bundle.main.bundleIdentifier
    /// - category: RingPublishingTracking
    public var loggerOutput: ((_ message: String) -> Void)? {
        get {
            return Logger.shared.loggerOutput
        }
        set {
            Logger.shared.loggerOutput = newValue
        }
    }

    // MARK: Private properties

    // TODO: refactor to use here class responsible for building and decorating events
    private let eventsManager = EventsManager()

    /// Module delegate
    private weak var delegate: RingPublishingTrackingDelegate?

    // MARK: Initializer

    private init() {
        // Nothing to do here at the moment
    }

    /// Configure RingPublishingTracking module
    ///
    /// - Parameters:
    ///   - configuration: RingPublishingTrackingConfiguration
    ///   - delegate: RingPublishingTrackingDelegate
    public func initialize(configuration: RingPublishingTrackingConfiguration, delegate: RingPublishingTrackingDelegate?) {
        Logger.log("Initializing module with configuration: '\(configuration)'")

        self.delegate = delegate

        // TODO: Implementation missing
    }

    // MARK: Debug mode / opt-out mode

    /// Enable / disable debug mode
    /// If debug mode is enabled, no network calls are being made but module will process all events and report console logs
    ///
    /// - Parameter enabled: Bool
    public func setDebugMode(enabled: Bool) {
        Logger.log("Setting debug mode enabled: '\(enabled)'")

        // TODO: Implementation missing
    }

    /// Enable / disable opt-out mode
    /// If opt-out mode is enabled, module will ignore all subsequent method calls and do nothing.
    /// Console logs are not enabled in this mode.
    ///
    /// - Parameter enabled: Bool
    public func setOptOutMode(enabled: Bool) {
        Logger.log("Setting opt-out mode enabled: '\(enabled)'")

        // TODO: Implementation missing
    }

    // MARK: Generic event

    /// Reports generic event which is not predefined in module
    ///
    /// - Parameter event: Event
    public func reportEvent(_ event: Event) {
        reportEvents([event])
    }

    /// Reports many generic events at once which are not predefined in module
    ///
    /// - Parameter events: [Event]
    public func reportEvents(_ events: [Event]) {
        Logger.log("Reporting generic events, events count: '\(events.count)'")

        // TODO: Implementation missing
        eventsManager.addEvents(events)
    }
}
