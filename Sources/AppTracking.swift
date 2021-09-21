//
//  AppTracking.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Main class for AppTracking module
public class AppTracking {

    // MARK: Public properties

    /// Shared instance
    public static let shared = AppTracking()

    /// Tracking identifier assigned by the module for this device
    public private(set) var trackingIdentifier: String?

    /// Closure which can be used to gather module logs inside host application
    ///
    /// Module is using os_log to report what is happening - but if this is not enough you can get all logged messages using this closure
    /// For os_log there is defined:
    /// - subsystem: Bundle.main.bundleIdentifier
    /// - category: AppTracking
    public var loggerOutput: ((_ message: String) -> Void)? {
        get {
            return Logger.shared.loggerOutput
        }
        set {
            Logger.shared.loggerOutput = newValue
        }
    }

    // MARK: Private properties

    private let eventsManager = EventsManager()

    /// Module delegate
    private weak var delegate: AppTrackingDelegate?

    // MARK: Initializer

    private init() {
        // Nothing to do here at the moment
    }

    /// Configure AppTracking module
    ///
    /// - Parameters:
    ///   - configuration: AppTrackingConfiguration
    ///   - delegate: AppTrackingDelegate
    public func initialize(configuration: AppTrackingConfiguration, delegate: AppTrackingDelegate?) {
        self.delegate = delegate

        // TODO: Implementation missing
    }

    // MARK: Debug mode / opt-out mode

    /// Enable / disable debug mode
    /// If debug mode is enabled, no network calls are being made but module will process all events and report console logs
    ///
    /// - Parameter enabled: Bool
    public func setDebugMode(enabled: Bool) {
        // TODO: Implementation missing
    }

    /// Enable / disable opt-out mode
    /// If opt-out mode is enabled, module will ignore all subsequent method calls and do nothing.
    /// Console logs are not enabled in this mode.
    ///
    /// - Parameter enabled: Bool
    public func setOptOutMode(enabled: Bool) {
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
        // TODO: Implementation missing
        eventsManager.addEvents(events)
    }
}
