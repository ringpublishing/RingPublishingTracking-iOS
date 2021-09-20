//
//  AppTracking.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to 'Content Performance Monitor'
public extension AppTracking {

    // MARK: Click event

    /// Reports click event for given app element
    ///
    /// - If user selected icon, element name can be omitted
    /// - For reporting click leading to article content, see `reportContentClick(...)`
    ///
    /// - Parameter selectedElementName: String
    func reportClick(selectedElementName: String?) {
        Logger.log("Reporting click event for element named: '\(selectedElementName.logable)'")

        // TODO: Implementation missing
    }

    // MARK: Content click event

    /// Reports click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    func reportContentClick(selectedElementName: String, publicationUrl: URL) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting content click event for element named: \(logData)")

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
    func reportUserAction(actionName: String, actionSubtypeName: String, parameters: [String: AnyHashable]) {
        // TODO: Implementation missing
    }

    /// Reports user action event
    /// Passed parameters as String could be just a plain string value or JSON
    ///
    /// - Parameters:
    ///   - actionName: String
    ///   - actionSubtypeName: String
    ///   - parameters: [String: AnyHashable]
    func reportUserAction(actionName: String, actionSubtypeName: String, parameters: String) {
        // TODO: Implementation missing
    }

    // MARK: Page view event

    /// Reports page view event.
    ///
    /// - Use this method if you want to report page view event which is not article content.
    /// - For reporting article content, see `reportContentPageView(...)`
    ///
    /// - Parameter partiallyReloaded: Pass true if you content was partially reloaded,
    /// for example next page of articles on the list was added or paid content was presented after user paid for it on the same screen.
    func reportPageView(partiallyReloaded: Bool) {
        Logger.log("Reporting page view event, partially reloaded: '\(partiallyReloaded)'")

        // TODO: Implementation missing
    }

    // MARK: Content page view event & keep alive

    /// Reports content page view event and immediately starts content keep alive tracking.
    ///
    /// - Use this method if you want to report article content page view event.
    /// - Only one content at the time can be tracked.
    /// - Reporting new content page view stops current tracking and start tracking for new content.
    ///
    /// - Parameters:
    ///   - contentMetdata: ContentMetadata
    ///   - pageViewSource: ContentPageViewSource
    ///   - partiallyReloaded: Pass true if you content was partially reloaded, for example content was refreshed after in app purchase
    ///   - contentKeepAliveDataSource: AppTrackingKeepAliveDataSource
    func reportContentPageView(contentMetadata: ContentMetadata,
                               pageViewSource: ContentPageViewSource = .default,
                               partiallyReloaded: Bool,
                               contentKeepAliveDataSource: AppTrackingKeepAliveDataSource) {
        Logger.log("Reporting content page view event for metadata: '\(contentMetadata)' and page view source: '\(pageViewSource)'")

        // TODO: Implementation missing
    }

    /// Pauses tracking for currently displayed content
    func pauseContentKeepAliveTracking() {
        Logger.log("Pausing content keep alive tracking")

        // TODO: Implementation missing
    }

    /// Resumes tracking for currently displayed content
    func resumeContentKeepAliveTracking() {
        Logger.log("Resuming content keep alive tracking")

        // TODO: Implementation missing
    }

    /// Stops tracking for currently displayed content
    func stopContentKeepAliveTracking() {
        Logger.log("Stopping content keep alive tracking")

        // TODO: Implementation missing
    }
}
