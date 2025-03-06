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
    public internal(set) var trackingIdentifier: TrackingIdentifier? {
        didSet {
            guard let trackingIdentifier = trackingIdentifier else { return }
            delegate?.ringPublishingTracking(self, didAssignTrackingIdentifier: trackingIdentifier)
        }
    }

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

    // MARK: Internal properties

    /// Events service for handling all operations on events
    var eventsService: EventsService?

    /// Events factory for creating specific events
    let eventsFactory = EventsFactory()

    /// Keep alive event manager
    let keepAliveManager = KeepAliveManager()

    // MARK: Private properties

    /// Keep alive event manager
    private let operationMode = OperationMode()

    /// Module delegate
    weak var delegate: RingPublishingTrackingDelegate?

    // MARK: Initializer

    private init() {}

    /// Configure RingPublishingTracking module
    ///
    /// - Parameters:
    ///   - configuration: RingPublishingTrackingConfiguration
    ///   - delegate: RingPublishingTrackingDelegate
    public func initialize(configuration: RingPublishingTrackingConfiguration, delegate: RingPublishingTrackingDelegate?) {
        Logger.log("Initializing module with configuration: '\(configuration)'")
        eventsService = EventsService(configuration: configuration, eventsFactory: eventsFactory, operationMode: operationMode)
        self.delegate = delegate
        keepAliveManager.delegate = self
        eventsService?.setup(delegate: self)
        eventsService?.updateApplicationAdvertisementArea(configuration.applicationDefaultAdvertisementArea)
        eventsService?.updateTenantId(tenantId: configuration.tenantId)
        eventsService?.updateApplicationRootPath(applicationRootPath: configuration.applicationRootPath)
        eventsService?.updateApplicationAdvertisementSite(applicationAdvertisementSite: configuration.applicationAdvertisementSite)
        eventsService?.updateStructureType(structureType: .structurePath(configuration.applicationDefaultStructurePath),
                                          contentPageViewSource: nil)
    }

    // MARK: Debug mode / opt-out mode

    /// Enable / disable debug mode
    /// If debug mode is enabled, no network calls are being made but module will process all events and report console logs
    ///
    /// - Parameter enabled: Bool
    public func setDebugMode(enabled: Bool) {
        Logger.log("Setting debug mode enabled: '\(enabled)'")

        operationMode.debugEnabled = enabled
    }

    /// Enable / disable opt-out mode
    /// If opt-out mode is enabled, module will ignore all subsequent method calls and do nothing.
    /// Console logs are not enabled in this mode.
    ///
    /// - Parameter enabled: Bool
    public func setOptOutMode(enabled: Bool) {
        Logger.log("Setting opt-out mode enabled: '\(enabled)'")

        operationMode.optOutEnabled = enabled
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

        for event in events {
            let eventParameters = event.eventParameters.mapValues { "\(String(describing: $0))" }
            Logger.log("Reporting generic event: \(event.eventName), parameters:\n\(eventParameters) ")
        }

        eventsService?.addEvents(events)
    }
}
