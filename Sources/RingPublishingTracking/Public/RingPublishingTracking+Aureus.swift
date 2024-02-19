//
//  RingPublishingTracking.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to 'Aureus'
public extension RingPublishingTracking {

    // MARK: Aureus events

    /// Reports 'Aureus' impression event
    ///
    /// - Parameters:
    ///   - teasers: [AureusTeaser]
    ///   - eventContext: AureusEventContext
    func reportAureusImpression(for teasers: [AureusTeaser], eventContext: AureusEventContext) {
        Logger.log("Reporting 'Aureus' impression event for teasers: '\(teasers)'")

        let event = eventsFactory.createAureusImpressionEvent(for: teasers, eventContext: eventContext)
        reportEvents([event])
    }

    /// Reports 'Aureus' click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    ///   - aureusOfferId: String
    ///   - teaser: AureusTeaser
    ///   - eventContext: AureusEventContext
    func reportContentClick(selectedElementName: String,
                            publicationUrl: URL,
                            aureusOfferId: String,
                            teaser: AureusTeaser,
                            eventContext: AureusEventContext) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting 'Aureus' content click event for element named: \(logData)")

        let clickEvent = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                        publicationUrl: publicationUrl,
                                                        contentIdentifier: teaser.contentId)

        var parameters = clickEvent.eventParameters
        parameters["EI"] = aureusOfferId

        var updatedContext = eventContext
        updatedContext.teaserId = teaser.teaserId

        if let ecxParameter = updatedContext.ecxParameter {
            parameters["ECX"] = ecxParameter
        }

        let event = Event(analyticsSystemName: clickEvent.analyticsSystemName,
                          eventName: clickEvent.eventName,
                          eventParameters: parameters)

        reportEvents([event])
    }
}
