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
    public var trackingIdentifier: String?

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

    // MARK: Dynamic tracking properties

    /// Update application user identifier for tracking purpose.
    /// If user is not logged in, pass nil as 'userId'.
    ///
    /// - Parameters:
    ///   - ssoSystemName: Name of SSO system used to login
    ///   - userId: User identifier
    public func updateApplicationUserData(ssoSystemName: String, userId: String?) {
        // TODO: Implementation missing
    }

    /// Update application area used to identify application screen, for example "list/sport".
    ///
    /// - Parameter currentAppArea: String
    public func updateApplicationArea(currentAppArea: String) {
        // TODO: Implementation missing
    }

    /// Update ad space name of the application, for example "ads/list/sport"
    ///
    /// - Parameter currentAdvertisementArea: String
    public func updateApplicationAdvertisementArea(currentAdvertisementArea: String) {
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
    }

    // MARK: Click event

    /// Reports click event for given app element
    ///
    /// - If user selected icon, element name can be omitted
    ///
    /// - Parameter selectedElementName: String
    public func reportClick(selectedElementName: String?) {
        // TODO: Implementation missing
    }

    // MARK: Content click event

    /// Reports click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    public func reportContentClick(selectedElementName: String, publicationUrl: URL) {
        // TODO: Implementation missing
    }

    // MARK: User action event

    /// Reports user action event
    /// Passed dictionary with parameters will be encoded to JSON
    ///
    /// - Parameters:
    ///   - actionName: String
    ///   - actionSubtypeName: String
    ///   - parameters: [String: AnyHashable]
    public func reportUserAction(actionName: String, actionSubtypeName: String, parameters: [String: AnyHashable]) {
        // TODO: Implementation missing
    }

    /// Reports user action event
    /// Passed parameters as String could be just a plain string value or JSON
    ///
    /// - Parameters:
    ///   - actionName: String
    ///   - actionSubtypeName: String
    ///   - parameters: [String: AnyHashable]
    public func reportUserAction(actionName: String, actionSubtypeName: String, parameters: String) {
        // TODO: Implementation missing
    }

    // MARK: Page view event

    /// Reports page view event.
    ///
    /// - Use this method if you want to report page view event which is not article content.
    /// - For reporting artile content, see `reportContentPageView(...)`
    ///
    /// - Parameter partiallyReloaded: Pass true if you content was partially reloaded,
    /// for example next page of articles on the list was added
    public func reportPageView(partiallyReloaded: Bool) {
        // TODO: Implementation missing
    }

    // MARK: Content page view event & content activity tracking (keep alive)

    /// Reports content page view event and immediately starts content activity tracking (also known as 'keep alive').
    ///
    /// - Use this method if you want to report article content page view event.
    /// - Only one content at the time can be tracked.
    /// - Reporting new content page view stops current tracking and start tracking for new content.
    ///
    /// - Parameters:
    ///   - contentMetdata: ContentMetadata
    ///   - pageViewSource: ContentPageViewSource
    ///   - partiallyReloaded: Pass true if you content was partially reloaded, for example content was refreshed after in app purchase
    ///   - contentActivityDataSource: AppTrackingContentActivityDataSource
    public func reportContentPageView(contentMetadata: ContentMetadata,
                                      pageViewSource: ContentPageViewSource = .default,
                                      partiallyReloaded: Bool,
                                      contentActivityDataSource: AppTrackingContentActivityDataSource) {
        // TODO: Implementation missing
    }

    /// Pauses tracking for currently displayed content
    public func pauseContentActivityTracking() {
        // TODO: Implementation missing
    }

    /// Resumes tracking for currently displayed content
    public func resumeContentActivityTracking() {
        // TODO: Implementation missing
    }

    /// Stops tracking for currently displayed content
    public func stopContentActivityTracking() {
        // TODO: Implementation missing
    }

    // MARK: Aureus events

    /// Reports 'Aureus' offers impression event
    ///
    /// - Parameter offerIds: [String]
    public func reportAureusOffersImpressions(offerIds: [String]) {
        // TODO: Implementation missing
    }
}
