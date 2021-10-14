//
//  EventsFactory.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class EventsFactory {

    func createClickEvent(selectedElementName: String?, publicationUrl: URL?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        if let selectedElementName = selectedElementName {
            parameters["VE"] = selectedElementName
        }

        if let publicationUrl = publicationUrl {
            parameters["VU"] = publicationUrl.absoluteString
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaEvents.rawValue,
                     eventName: EventType.click.rawValue,
                     eventParameters: parameters)
    }

    func createUserActionEvent(actionName: String, actionSubtypeName: String, parameter: UserActionParameter) -> Event {
        var parameters: [String: AnyHashable] = [
            "VE": actionName,
            "VC": actionSubtypeName
        ]

        let payload: String?

        switch parameter {
        case .parameters(let dictionary):
            if let data = try? dictionary.dataUsingJSONSerialization(),
               let string = String(data: data, encoding: .utf8) {
                payload = string
            } else {
                payload = nil
                Logger.log("Could not parse given parameters to JSON")
            }
        case .plain(let string):
            payload = string
        }

        if let payload = payload {
            parameters["VM"] = payload
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaEvents.rawValue,
                     eventName: EventType.userAction.rawValue,
                     eventParameters: parameters)
    }

    func createPageViewEvent(publicationIdentifier: String?, contentMetadata: ContentMetadata?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        if let publicationIdentifier = publicationIdentifier {
            parameters["PU"] = publicationIdentifier
        }

        if let contentMetadata = contentMetadata {
            let sourceSystem = contentMetadata.sourceSystemName
            let pubId = contentMetadata.publicationId
            let part = contentMetadata.contentPartIndex
            let paid = contentMetadata.contentWasPaidFor ? "t" : "f"

            parameters["DX"] = "PV_4,\(sourceSystem),\(pubId),\(part),\(paid)"
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaStats.rawValue,
                     eventName: EventType.pageView.rawValue,
                     eventParameters: parameters)
    }

    func createAureusOffersImpressionEvent(offerIds: [String]) -> Event {
        let offerIdsString = offerIds.joined(separator: "\",\"")

        let encodedListString: String?
        if offerIds.isEmpty {
            encodedListString = nil
        } else {
            encodedListString = "[\"\(offerIdsString)\"]".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }

        return createUserActionEvent(actionName: "aureusOfferImpressions",
                                     actionSubtypeName: "offerIds",
                                     parameter: .plain(encodedListString))
    }
}
