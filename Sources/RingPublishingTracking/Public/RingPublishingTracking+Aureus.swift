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

        let event = eventsFactory.createAureusOffersImpressionEvent(offerIds: offerIds)
        reportEvents([event])
    }

    /// Reports 'Aureus' click event which leads to content page
    ///
    /// - Parameters:
    ///   - selectedElementName: String
    ///   - publicationUrl: URL
    ///   - publicationId: String
    ///   - aureusOfferId: String
    func reportContentClick(selectedElementName: String, publicationUrl: URL, publicationId: String?, aureusOfferId: String?) {
        let logData = "'\(selectedElementName)' and publication url: '\(publicationUrl.absoluteString)'"
        Logger.log("Reporting 'Aureus' content click event for element named: \(logData)")

        let event = eventsFactory.createClickEvent(selectedElementName: selectedElementName,
                                                   publicationUrl: publicationUrl,
                                                   publicationIdentifier: publicationId,
                                                   aureusOfferId: aureusOfferId)
        reportEvents([event])
    }
}
