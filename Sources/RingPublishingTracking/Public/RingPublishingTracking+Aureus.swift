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

    /// Reports 'Aureus' offers impression event
    ///
    /// - Parameter offerIds: [String]
    func reportAureusOffersImpressions(offerIds: [String]) {
        Logger.log("Reporting 'Aureus' offers impression event for offers: '\(offerIds)'")

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

    /// Reports 'Aureus' click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    ///   - publicationId: String
    ///   - aureusOfferId: String
    func reportContentClick(selectedElementName: String, publicationUrl: URL, publicationId: String, aureusOfferId: String) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting 'Aureus' content click event for element named: \(logData)")

        let clickEvent = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                        publicationUrl: publicationUrl,
                                                        publicationIdentifier: publicationId)

        var parameters = clickEvent.eventParameters
        parameters["EI"] = aureusOfferId

        let event = Event(analyticsSystemName: clickEvent.analyticsSystemName,
                          eventName: clickEvent.eventName,
                          eventParameters: parameters)

        reportEvents([event])
    }
}
