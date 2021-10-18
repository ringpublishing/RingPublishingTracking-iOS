//
//  RingPublishingTracking.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to 'Content Performance Monitor'
public extension RingPublishingTracking {

    // MARK: Click event

    /// Reports click event for given app element
    ///
    /// - If user selected icon, element name can be omitted
    /// - For reporting click leading to article content, see `reportContentClick(...)`
    ///
    /// - Parameter selectedElementName: String
    func reportClick(selectedElementName: String?) {
        Logger.log("Reporting click event for element named: '\(selectedElementName.logable)'")

        let event = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                   publicationUrl: nil,
                                                   publicationIdentifier: nil,
                                                   aureusOfferId: nil)
        reportEvents([event])
    }

    // MARK: Content click event

    /// Reports click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    ///   - publicationId: String
    func reportContentClick(selectedElementName: String, publicationUrl: URL, publicationId: String?) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting content click event for element named: \(logData)")

        let event = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                   publicationUrl: publicationUrl,
                                                   publicationIdentifier: publicationId,
                                                   aureusOfferId: nil)
        reportEvents([event])
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
        Logger.log("Reporting user action named: '\(actionName)', subtypeName: '\(actionSubtypeName)'")

        let event = eventsFactory.createUserActionEvent(actionName: actionName,
                                                        actionSubtypeName: actionSubtypeName,
                                                        parameter: .parameters(parameters))
        reportEvents([event])
    }

    /// Reports user action event
    /// Passed parameters as String could be just a plain string value or JSON
    ///
    /// - Parameters:
    ///   - actionName: String
    ///   - actionSubtypeName: String
    ///   - parameters: [String: AnyHashable]
    func reportUserAction(actionName: String, actionSubtypeName: String, parameters: String) {
        Logger.log("Reporting user action named: '\(actionName)', subtypeName: '\(actionSubtypeName)'")

        let event = eventsFactory.createUserActionEvent(actionName: actionName,
                                                        actionSubtypeName: actionSubtypeName,
                                                        parameter: .plain(parameters))
        reportEvents([event])
    }

    // MARK: Page view event

    /// Reports page view event.
    ///
    /// - Use this method if you want to report page view event which is not article content.
    /// - For reporting article content, see `reportContentPageView(...)`
    ///
    /// - Parameters:
    ///   - currentStructurePath: Current application structure path used to identify application screen,
    ///   for example "home/sport_list_screen"
    ///   - partiallyReloaded: Pass true if your content was partially reloaded,
    ///   for example next page of articles on the list was added or paid content was presented after user paid for it on the same screen.
    func reportPageView(currentStructurePath: [String], partiallyReloaded: Bool) {
        Logger.log("Reporting page view event, structure path: '\(currentStructurePath)', partially reloaded: '\(partiallyReloaded)'")

        eventsService.updateUniqueIdentifier(partiallyReloaded: partiallyReloaded)
        eventsService.updateStructureType(structureType: .structurePath(currentStructurePath), contentPageViewSource: nil)

        let event = eventsFactory.createPageViewEvent(publicationIdentifier: nil, contentMetadata: nil)
        reportEvents([event])
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
    ///   - currentStructurePath: Current application structure path used to identify application screen,
    ///   for example "home/sport_list_screen"
    ///   - partiallyReloaded: Pass true if your content was partially reloaded, for example content was refreshed after in app purchase
    ///   - contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource
    func reportContentPageView(contentMetadata: ContentMetadata,
                               pageViewSource: ContentPageViewSource = .default,
                               currentStructurePath: [String],
                               partiallyReloaded: Bool,
                               contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource) {
        let log = """
        Reporting content page view event for metadata: '\(contentMetadata)' and page view source: '\(pageViewSource)',
        structure path: '\(currentStructurePath)'
        """
        Logger.log(log)

        eventsService.updateUniqueIdentifier(partiallyReloaded: partiallyReloaded)
        eventsService.updateStructureType(structureType: .publicationUrl(contentMetadata.publicationUrl, currentStructurePath),
                                          contentPageViewSource: pageViewSource)

        let event = eventsFactory.createPageViewEvent(publicationIdentifier: contentMetadata.publicationId,
                                                      contentMetadata: contentMetadata)
        reportEvents([event])
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
