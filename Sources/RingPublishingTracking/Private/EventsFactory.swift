//
//  EventsFactory.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class EventsFactory {

    func createClickEvent(selectedElementName: String?,
                          publicationUrl: URL?,
                          publicationIdentifier: String?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        if let selectedElementName = selectedElementName {
            parameters["VE"] = selectedElementName
        }

        if let publicationUrl = publicationUrl {
            parameters["VU"] = publicationUrl.absoluteString
        }

        if let publicationIdentifier = publicationIdentifier {
            parameters["PU"] = publicationIdentifier
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
            parameters["DX"] = contentMetadata.dxParameter
        }

        return Event(analyticsSystemName: AnalyticsSystem.kropkaStats.rawValue,
                     eventName: EventType.pageView.rawValue,
                     eventParameters: parameters)
    }

    func createKeepAliveEvent(metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) -> Event {
        var parameters: [String: AnyHashable] = [:]

        let measurements = metaData.keepAliveContentStatus

        parameters["DX"] = contentMetadata.dxParameter
        parameters["KDS"] = measurements.map { "\(Int($0.contentSize.width))x\(Int($0.contentSize.height))" }
        parameters["KHF"] = metaData.hasFocus
        parameters["KMT"] = metaData.keepAliveMeasureType.map { $0.rawValue }
        parameters["KTA"] = 1
        parameters["KTP"] = metaData.timings
        parameters["KTS"] = measurements.map { Int($0.scrollOffset) }

        return Event(analyticsSystemName: AnalyticsSystem.timescore.rawValue,
                     eventName: EventType.keepAlive.rawValue,
                     eventParameters: parameters)
    }
}
