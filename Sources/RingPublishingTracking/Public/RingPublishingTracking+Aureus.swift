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
        Logger.log("Reporting 'Aureus' offers impression event for teasers: '\(teasers)'")

        switch eventContext.shouldUseLegacyReporting {
        case true:
            reportLegacyAureusOffersImpression(for: teasers, eventContext: eventContext)

        case false:
            reportNewAureusOffersImpression(for: teasers, eventContext: eventContext)
        }
    }

    /// Reports 'Aureus' click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    ///   - teaser: AureusTeaser
    ///   - eventContext: AureusEventContext
    func reportContentClick(selectedElementName: String,
                            publicationUrl: URL,
                            teaser: AureusTeaser,
                            eventContext: AureusEventContext) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting 'Aureus' content click event for element named: \(logData)")

        switch eventContext.shouldUseLegacyReporting {
        case true:
            reportLegacyContentClick(selectedElementName: selectedElementName,
                                     publicationUrl: publicationUrl,
                                     teaser: teaser,
                                     eventContext: eventContext)

        case false:
            reportNewContentClick(selectedElementName: selectedElementName,
                                  publicationUrl: publicationUrl,
                                  teaser: teaser,
                                  eventContext: eventContext)
        }
    }
}

// MARK: Private
private extension RingPublishingTracking {

    // MARK: Legacy events

    func reportLegacyAureusOffersImpression(for teasers: [AureusTeaser], eventContext: AureusEventContext) {
        let offerIds = teasers.compactMap { $0.offerId }
        let offerIdsString = offerIds.joined(separator: "\",\"")

        let encodedListString: String?
        if offerIds.isEmpty {
            encodedListString = nil
        } else {
            encodedListString = "[\"\(offerIdsString)\"]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }

        let event = eventsFactory.createUserActionEvent(actionName: "aureusOfferImpressions",
                                                        actionSubtypeName: "offerIds",
                                                        parameter: .plain(encodedListString))
        reportEvents([event])
    }

    func reportLegacyContentClick(selectedElementName: String,
                                  publicationUrl: URL,
                                  teaser: AureusTeaser,
                                  eventContext: AureusEventContext) {
        let clickEvent = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                        publicationUrl: publicationUrl,
                                                        contentIdentifier: teaser.contentId)

        var parameters = clickEvent.eventParameters

        if let aureusOfferId = teaser.offerId {
            parameters["EI"] = aureusOfferId
        }

        let event = Event(analyticsSystemName: clickEvent.analyticsSystemName,
                          eventName: clickEvent.eventName,
                          eventParameters: parameters)

        reportEvents([event])
    }

    // MARK: New events

    func reportNewAureusOffersImpression(for teasers: [AureusTeaser], eventContext: AureusEventContext) {
        let event = eventsFactory.createAureusImpressionEvent(for: teasers, eventContext: eventContext)
        reportEvents([event])
    }

    func reportNewContentClick(selectedElementName: String,
                               publicationUrl: URL,
                               teaser: AureusTeaser,
                               eventContext: AureusEventContext) {
        let clickEvent = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                        publicationUrl: publicationUrl,
                                                        contentIdentifier: teaser.contentId)

        var parameters = clickEvent.eventParameters

        if let aureusOfferId = teaser.offerId {
            parameters["EI"] = aureusOfferId
        }

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
