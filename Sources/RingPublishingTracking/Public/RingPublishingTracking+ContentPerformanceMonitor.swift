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
                                                   contentIdentifier: nil)
        reportEvents([event])
    }

    // MARK: Content click event

    /// Reports click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    ///   - contentId: String
    func reportContentClick(selectedElementName: String, publicationUrl: URL, contentId: String) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting content click event for element named: \(logData)")

        let event = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                   publicationUrl: publicationUrl,
                                                   contentIdentifier: contentId)
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

        eventsService?.updateUniqueIdentifier(partiallyReloaded: partiallyReloaded)
        eventsService?.updateStructureType(structureType: .structurePath(currentStructurePath), contentPageViewSource: nil)

        let event = eventsFactory.createPageViewEvent(contentIdentifier: nil, contentMetadata: nil)
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

        eventsService?.updateUniqueIdentifier(partiallyReloaded: partiallyReloaded)
        eventsService?.updateStructureType(structureType: .publicationUrl(contentMetadata.publicationUrl, currentStructurePath),
                                          contentPageViewSource: pageViewSource)

        // When new content is open reset effective page view sent flag
        if !partiallyReloaded {
            eventsFactory.isEffectivePageViewEventSent = false
        }

        let event = eventsFactory.createPageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                      contentMetadata: contentMetadata)
        reportEvents([event])

        // Start keepAlive
        Logger.log("Starting content keep alive tracking")
        keepAliveManager.start(for: contentMetadata,
                               contentKeepAliveDataSource: contentKeepAliveDataSource,
                               partiallyReloaded: partiallyReloaded)
    }

    /// Pauses tracking for currently displayed content
    func pauseContentKeepAliveTracking() {
        Logger.log("Pausing content keep alive tracking")

        keepAliveManager.pause()
    }

    /// Resumes tracking for currently displayed content
    func resumeContentKeepAliveTracking() {
        Logger.log("Resuming content keep alive tracking")

        keepAliveManager.resume()
    }

    /// Stops tracking for currently displayed content
    func stopContentKeepAliveTracking() {
        Logger.log("Stopping content keep alive tracking")

        keepAliveManager.stop()
    }

    /// Reports effective page view event.
    ///
    /// - Use this method if you want to report an effective page view event, which indicates that the user has actively viewed the content
    ///   (e.g. after scrolling or reaching specific thresholds).
    /// - Effective page view can be reported only one time for the same content
    /// - This method does not affect keep alive tracking.
    ///
    /// - Parameters:
    ///   - contentMetadata: ContentMetadata
    ///   - pageViewSource: ContentPageViewSource (default: `.default`)
    ///   - currentStructurePath: Current application structure path used to identify application screen,
    ///   for example "home/sport_list_screen"
    ///   - partiallyReloaded: Pass true if your content was partially reloaded, for example content was refreshed after in app purchase
    ///   - componentSource: Source of the UI component which triggered effective page view (e.g. audio/video player, onetchat)
    ///   - triggerSource: Source of the trigger which caused effective page view reporting (e.g. scroll, play pressed)

    func reportEffectivePageView(contentMetadata: ContentMetadata,
                                 componentSource: EffectivePageViewComponentSource,
                                 triggerSource: EffectivePageViewTriggerSource) {
        guard configuration?.shouldReportEffectivePageViewEvent == true else {
            Logger.log("Effective page view event reporting is disabled in configuration")
            return
        }

        Logger.log("Reporting effective page view event for metadata: '\(contentMetadata)', " +
                   "component source: '\(componentSource.value)', trigger source: '\(triggerSource.value)''")

        let metaData = EffectivePageViewMetadata(componentSource: componentSource,
                                                 triggerSource: triggerSource,
                                                 measurement: keepAliveManager.lastMeasurement ?? .zero)

        guard let event = eventsFactory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                                     contentMetadata: contentMetadata,
                                                                     metaData: metaData) else {
            Logger.log("Reporting effective page view has been already done for current content: \(contentMetadata)")
            return
        }

        reportEvents([event])
    }
}
